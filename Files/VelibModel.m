//
//  VelibModel.m
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "VelibModel.h"
#import "Station.h"
#import "Region.h"
#import "NSArrayAdditions.h"
#import "NSStringAdditions.h"

#import "DataUpdater.h"

/****************************************************************************/
#pragma mark -

@interface VelibModel () <DataUpdaterDelegate, NSXMLParserDelegate>
@property (nonatomic, retain) DataUpdater * updater;
@property BOOL updatingXML;
// -
@property (nonatomic, retain) NSDictionary * stationsHardcodedFixes;
// -
@property (readonly, nonatomic, readwrite) MKCoordinateRegion coordinateRegion;
@end

/****************************************************************************/
#pragma mark -

@implementation VelibModel

@synthesize updater;
@synthesize updatingXML;
@synthesize stationsHardcodedFixes;
@synthesize coordinateRegion;

- (id)init {
    self = [super init];
    if (self) {
        self.updater = [DataUpdater updaterWithDelegate:self];
    }
    return self;
}
- (void) dealloc
{
    self.updater = nil;
	self.stationsHardcodedFixes = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark Hardcoded Fixes

- (NSDictionary*) stationsHardcodedFixes
{
	if(nil==stationsHardcodedFixes)
	{
		NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VelibHardcodedFixes" ofType:@"plist"]];
		self.stationsHardcodedFixes = [dict objectForKey:@"stations"];
	}
	return [[stationsHardcodedFixes retain] autorelease];
}

/****************************************************************************/
#pragma mark Parsing

- (NSTimeInterval) refreshIntervalForUpdater:(DataUpdater *)updater
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:@"DatabaseReloadInterval"];
}

- (NSURL*) urlForUpdater:(DataUpdater *)updater
{
    return [NSURL URLWithString:kVelibStationsListURL];    
}
- (NSString*) knownDataSha1ForUpdater:(DataUpdater*)updater
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"Database_XML_SHA1"];
}

- (void) setUpdater:(DataUpdater*)updater knownDataSha1:(NSString*)sha1
{
    [[NSUserDefaults standardUserDefaults] setObject:sha1 forKey:@"Database_XML_SHA1"];
}

- (NSDate*) dataDateForUpdater:(DataUpdater*)updater
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"DatabaseCreateDate"];
}

- (void) setUpdater:(DataUpdater*)updater dataDate:(NSDate*)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"DatabaseCreateDate"];
}

- (void) updaterDidFinish:(DataUpdater*)updater
{
    self.updater = nil;
}

- (void) updater:(DataUpdater*)updater receivedUpdatedData:(NSData*)xml
{
	self.updatingXML = YES;
    
	NSError * requestError = nil;
	
	// Remove old stations
	NSFetchRequest * oldStationsRequest = [[NSFetchRequest new] autorelease];
	[oldStationsRequest setEntity:[Station entityInManagedObjectContext:self.moc]];
	NSArray * oldStations = [self.moc executeFetchRequest:oldStationsRequest error:&requestError];
	NSLog(@"Removing %d old stations",[oldStations count]);
	for (Station * oldStation in oldStations) {
		[self.moc deleteObject:oldStation];
	}
	
	// Parse
	NSXMLParser * parser = [[[NSXMLParser alloc] initWithData:xml] autorelease];
	parser.delegate = self;
	[parser parse];
    
	// Compute regions coordinates
	NSFetchRequest * regionsRequest = [[NSFetchRequest new] autorelease];
	[regionsRequest setEntity:[Region entityInManagedObjectContext:self.moc]];
	NSArray * regions = [self.moc executeFetchRequest:regionsRequest error:&requestError];
	[regions makeObjectsPerformSelector:@selector(setupCoordinates)];
    
	// Save
	[self save];
	self.updatingXML = NO;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"marker"])
	{
		Station * station = [Station insertInManagedObjectContext:self.moc];
		[station setValuesForKeysWithDictionary:attributeDict]; // Yay! Security !
		NSDictionary * fixes = [self.stationsHardcodedFixes objectForKey:station.number];
		if(fixes)
		{
			NSLog(@"using hardcoded fixes for %@.\n\tReceived Data : %@.\n\tFixes : %@",station.number, attributeDict, fixes);
			[station setValuesForKeysWithDictionary:fixes]; // Yay! again
		}
        
        // Setup region
        if([station.fullAddress hasPrefix:station.address])
        {
            NSString * endOfAddress = [station.fullAddress stringByDeletingPrefix:station.address];
            endOfAddress = [endOfAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString * lCodePostal = nil;
            if(endOfAddress.length>=5)
                lCodePostal = [endOfAddress substringToIndex:5];
            if(nil==lCodePostal || [lCodePostal isEqualToString:@"75000"])
            {
                unichar firstChar = [station.number characterAtIndex:0];
                switch (firstChar) {
                    case '0': case '1':				// Paris
                        lCodePostal = [NSString stringWithFormat:@"750%@",[station.number substringToIndex:2]];
                        break;
                    case '2': case '3': case '4':	// Banlieue
                        lCodePostal = [NSString stringWithFormat:@"9%@0",[station.number substringToIndex:3]];
                        break;
                    default:						// Stations Mobiles et autres bugs
                        lCodePostal = [fixes objectForKey:@"codePostal"];
                        if(nil==lCodePostal)		// Dernier recours
                            lCodePostal = @"75000";
                        break;
                }
                
                NSLog(@"endOfAddress \"%@\" trop court, %@, trouvé %@",endOfAddress, station.name, lCodePostal);
            }
            NSAssert1([lCodePostal rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound,@"codePostal %@ contient des caractères invalides",lCodePostal);
            
            Region * region = [[Region fetchRegionWithNumber:self.moc number:lCodePostal] lastObject];
            if(nil==region)
            {
                region = [Region insertInManagedObjectContext:self.moc];
                region.number = lCodePostal;
                NSString * cityName = [[[endOfAddress stringByDeletingPrefix:region.number]
                                        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                                       capitalizedString];
                if([lCodePostal hasPrefix:@"75"])
                    region.name = [NSString stringWithFormat:@"%@ %@",cityName,[[lCodePostal substringFromIndex:3] stringByDeletingPrefix:@"0"]];
                else
                    region.name = cityName;
            }
            station.region = region;
        }
        else
        {
            NSLog(@"full address \"%@\" does not begin with address \"%@\"", station.fullAddress, station.address);
            NSLog(@"Invalid data : %@",attributeDict);
            [self.moc deleteObject:station];
        }
    }
}

/****************************************************************************/
#pragma mark Coordinates

- (MKCoordinateRegion) coordinateRegion
{
	if(coordinateRegion.center.latitude == 0 &&
	   coordinateRegion.center.longitude == 0 &&
	   coordinateRegion.span.latitudeDelta == 0 &&
	   coordinateRegion.span.longitudeDelta == 0 )
	{
		NSFetchRequest * regionsRequest = [[NSFetchRequest new] autorelease];
		[regionsRequest setEntity:[Region entityInManagedObjectContext:self.moc]];
		NSError * requestError = nil;
		NSArray * regions = [self.moc executeFetchRequest:regionsRequest error:&requestError];
        
		NSNumber * minLat = [regions valueForKeyPath:@"@min.minLat"];
		NSNumber * maxLat = [regions valueForKeyPath:@"@max.maxLat"];
		NSNumber * minLng = [regions valueForKeyPath:@"@min.minLng"];
		NSNumber * maxLng = [regions valueForKeyPath:@"@max.maxLng"];
		
		CLLocationCoordinate2D center;
		center.latitude = ([minLat doubleValue] + [maxLat doubleValue]) / 2.0f;
		center.longitude = ([minLng doubleValue] + [maxLng doubleValue]) / 2.0f; // This is very wrong ! Do I really need a if?
		MKCoordinateSpan span;
		span.latitudeDelta = fabs([minLat doubleValue] - [maxLat doubleValue]);
		span.longitudeDelta = fabs([minLng doubleValue] - [maxLng doubleValue]);
		self.coordinateRegion = MKCoordinateRegionMake(center, span);
	}
	return coordinateRegion;
}

@end

