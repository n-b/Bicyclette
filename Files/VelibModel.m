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
#import "Radar.h"
#import "NSArrayAdditions.h"
#import "NSStringAdditions.h"
#import "NSObject+KVCMapping.h"

#import "DataUpdater.h"

/****************************************************************************/
#pragma mark Constants

const struct VelibModelNotifications VelibModelNotifications = {
    .updateBegan = @"VelibModelNotifications.updateBegan",
    .updateGotNewData = @"VelibModelNotifications.updateGotNewData",
    .updateSucceeded = @"VelibModelNotifications.updateSucceded",
    .updateFailed = @"VelibModelNotifications.updateFailed",
    .keys = {
        .dataChanged = @"VelibModelNotifications.keys.dataChanged",
        .failureReason = @"VelibModelNotifications.keys.failureReason",
        .saveErrors = @"VelibModelNotifications.keys.saveErrors",
    }
};


/****************************************************************************/
#pragma mark -

@interface VelibModel () <DataUpdaterDelegate, NSXMLParserDelegate>
@property (nonatomic, strong) DataUpdater * updater;
// -
@property (nonatomic, strong) NSDictionary * stationsHardcodedFixes;
@property (readwrite, nonatomic, strong) CLRegion * hardcodedLimits;
// -
@property (nonatomic, readwrite) MKCoordinateRegion regionContainingData;
// - 
@property (nonatomic, strong) NSMutableDictionary * parsing_regionsByCodePostal;
@property (nonatomic, strong) NSMutableArray * parsing_oldStations;
@end

/****************************************************************************/
#pragma mark -

@implementation VelibModel

@synthesize updater;
@synthesize stationsHardcodedFixes;
@synthesize hardcodedLimits;
@synthesize regionContainingData;
@synthesize parsing_regionsByCodePostal;
@synthesize parsing_oldStations;

/****************************************************************************/
#pragma mark Hardcoded Fixes

- (NSDictionary*) hardcodedFixes
{
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VelibHardcodedFixes" ofType:@"plist"]];
}

- (NSDictionary*) stationsHardcodedFixes
{
	if(nil==stationsHardcodedFixes)
	{
		self.stationsHardcodedFixes = [self.hardcodedFixes objectForKey:@"stations"];
	}
	return stationsHardcodedFixes;
}

- (CLRegion*) hardcodedLimits
{
	if( nil==hardcodedLimits )
	{
        NSDictionary * dict = [self.hardcodedFixes objectForKey:@"limits"];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[dict objectForKey:@"latitude"] doubleValue], [[dict objectForKey:@"longitude"] doubleValue]);
        CLLocationDistance distance = [[dict objectForKey:@"distance"] doubleValue];
        self.hardcodedLimits = [[CLRegion alloc] initCircularRegionWithCenter:coord radius:distance identifier:NSStringFromClass([self class])];
	}
	return hardcodedLimits;
}

/****************************************************************************/
#pragma mark Update

- (void) updateIfNeeded
{
    if(self.updater==nil)
    {
        self.updater = [DataUpdater updaterWithDelegate:self];
    }
}

/****************************************************************************/
#pragma mark Updater Delegate

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

- (void) updaterDidBegin:(DataUpdater*)updater
{
    [[NSNotificationCenter defaultCenter] postNotificationName:VelibModelNotifications.updateBegan object:self];
}

- (void) updaterDidStartRequest:(DataUpdater *)updater
{
}

- (void) updater:(DataUpdater *)updater didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:VelibModelNotifications.updateFailed object:self userInfo:@{VelibModelNotifications.keys.failureReason : error}];
    self.updater = nil;
}

- (void) updater:(DataUpdater*)updater finishedWithNewData:(NSData*)xml
{
    [[NSNotificationCenter defaultCenter] postNotificationName:VelibModelNotifications.updateGotNewData object:self];
    
	NSError * requestError = nil;
	
	// Get Old Stations Names
	NSFetchRequest * oldStationsRequest = [NSFetchRequest new];
	[oldStationsRequest setEntity:[Station entityInManagedObjectContext:self.moc]];
    self.parsing_oldStations =  [[self.moc executeFetchRequest:oldStationsRequest error:&requestError] mutableCopy];
	
	// Parsing
    self.parsing_regionsByCodePostal = [NSMutableDictionary dictionary];
	NSXMLParser * parser = [[NSXMLParser alloc] initWithData:xml];
	parser.delegate = self;
	[parser parse];
    
    // Post processing :
	// Compute regions coordinates
    // and reorder stations in regions
    for (Region * region in [self.parsing_regionsByCodePostal allValues]) {
        [region.stationsSet sortUsingComparator:^NSComparisonResult(Station* obj1, Station* obj2) {
            return [obj1.name compare:obj2.name];
        }];
        [region setupCoordinates];
    }
    self.parsing_regionsByCodePostal = nil;

    // Delete Old Stations
	for (Station * oldStation in self.parsing_oldStations) {
        NSLog(@"Note : old station deleted after update : %@", oldStation);
		[self.moc deleteObject:oldStation];
	}
    self.parsing_oldStations = nil;
    
	// Save
    NSArray * errors;
    if ([self save:&errors])
    {
        NSMutableDictionary * userInfo = [@{VelibModelNotifications.keys.dataChanged : @YES} mutableCopy];
        if (errors)
            [userInfo setObject:errors forKey:VelibModelNotifications.keys.saveErrors];
        [[NSNotificationCenter defaultCenter] postNotificationName:VelibModelNotifications.updateSucceeded object:self
                                                          userInfo:userInfo];
    }
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:VelibModelNotifications.updateFailed object:self
                                                          userInfo:
         @{VelibModelNotifications.keys.failureReason : errors}];

    self.updater = nil;
}

- (void) updaterDidFinishWithNoNewData:(DataUpdater *)updater
{
    [[NSNotificationCenter defaultCenter] postNotificationName:VelibModelNotifications.updateSucceeded object:self userInfo:@{VelibModelNotifications.keys.dataChanged : @NO}];
    self.updater = nil;
}


/****************************************************************************/
#pragma mark Parser delegate

- (NSDictionary*) stationKVCMapping
{
    static NSDictionary * s_mapping = nil;
    if(nil==s_mapping)
        s_mapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                     @"address",@"address",
                     @"bonus",@"bonus",
                     @"fullAddress",@"fullAddress",
                     @"name",@"name",
                     @"number",@"number",
                     @"open",@"open",
                     
                     @"latitude",@"lat",
                     @"longitude",@"lng",
                     nil];
    
    return s_mapping;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"marker"])
	{
        // Filter out closed stations
        if( ! [[attributeDict objectForKey:@"open"] boolValue] )
        {
            NSLog(@"Note : Ignored closed station : %@", attributeDict);
            return;
        }
        
        // Find Existing Stations
        Station * station = [self.parsing_oldStations firstObjectWithValue:[attributeDict objectForKey:@"number"] forKey:StationAttributes.number];
        if(station)
        {
            // found existing
            [self.parsing_oldStations removeObject:station];
        }
        else
        {
            if(self.parsing_oldStations.count)
                NSLog(@"Note : new station found after update : %@", attributeDict);
            station = [Station insertInManagedObjectContext:self.moc];
        }

        // Set Values and hardcoded fixes
		[station setValuesForKeysWithDictionary:attributeDict withMappingDictionary:self.stationKVCMapping]; // Yay!
		NSDictionary * fixes = [self.stationsHardcodedFixes objectForKey:station.number];
		if(fixes)
		{
			NSLog(@"Note : Used hardcoded fixes %@. Fixes : %@.",attributeDict, fixes);
			[station setValuesForKeysWithDictionary:fixes withMappingDictionary:self.stationKVCMapping]; // Yay! again
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
                
                NSLog(@"Note : Used heuristics to find region for %@. Found : %@. ",attributeDict, lCodePostal);
            }
            NSAssert1([lCodePostal rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound,@"codePostal %@ contient des caractères invalides",lCodePostal);
            
            // Keep regions in an array locally, to avoid fetching a Region for every Station parsed.
            Region * region = [self.parsing_regionsByCodePostal objectForKey:lCodePostal];
            if(nil==region)
            {
                region = [Region insertInManagedObjectContext:self.moc];
                [self.parsing_regionsByCodePostal setObject:region forKey:lCodePostal];
                region.number = lCodePostal;
                if([lCodePostal hasPrefix:@"75"])
                    region.name = [NSString stringWithFormat:@"Paris %@",[[lCodePostal substringFromIndex:3] stringByDeletingPrefix:@"0"]];
                else
                {
                    NSString * cityName = [[[endOfAddress stringByDeletingPrefix:region.number]
                                            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                                           capitalizedString];
                    region.name = cityName;
                }
                NSLog(@"Created region %@",region.name);
            }
            station.region = region;
        }
        else
        {
            NSLog(@"Invalid data ('fulladdress' should begin with 'address'): %@",attributeDict);
            [self.moc deleteObject:station];
        }
    }
}

/****************************************************************************/
#pragma mark Radars

- (Radar *) userLocationRadar
{
    Radar * r = [[Radar fetchUserLocationRadar:self.moc] lastObject];
    if(r==nil)
    {
        r = [Radar insertInManagedObjectContext:self.moc];
        r.identifier = RadarIdentifiers.userLocation;
        [self save:nil];
    }
    return r;
}
- (Radar *) screenCenterRadar
{
    Radar * r = [[Radar fetchScreenCenterRadar:self.moc] lastObject];
    if(r==nil)
    {
        r = [Radar insertInManagedObjectContext:self.moc];
        r.identifier = RadarIdentifiers.screenCenter;
        [self save:nil];
    }
    return r;
}


/****************************************************************************/
#pragma mark Coordinates

- (MKCoordinateRegion) regionContainingData
{
	if(regionContainingData.center.latitude == 0 &&
	   regionContainingData.center.longitude == 0 &&
	   regionContainingData.span.latitudeDelta == 0 &&
	   regionContainingData.span.longitudeDelta == 0 )
	{
		NSFetchRequest * regionsRequest = [NSFetchRequest new];
		[regionsRequest setEntity:[Region entityInManagedObjectContext:self.moc]];
		NSError * requestError = nil;
		NSArray * regions = [self.moc executeFetchRequest:regionsRequest error:&requestError];
        
		NSNumber * minLat = [regions valueForKeyPath:@"@min.minLatitude"];
		NSNumber * maxLat = [regions valueForKeyPath:@"@max.maxLatitude"];
		NSNumber * minLng = [regions valueForKeyPath:@"@min.minLongitude"];
		NSNumber * maxLng = [regions valueForKeyPath:@"@max.maxLongitude"];
		
		CLLocationCoordinate2D center;
		center.latitude = ([minLat doubleValue] + [maxLat doubleValue]) / 2.0f;
		center.longitude = ([minLng doubleValue] + [maxLng doubleValue]) / 2.0f; // This is very wrong ! Do I really need a if?
		MKCoordinateSpan span;
		span.latitudeDelta = fabs([minLat doubleValue] - [maxLat doubleValue]);
		span.longitudeDelta = fabs([minLng doubleValue] - [maxLng doubleValue]);
		self.regionContainingData = MKCoordinateRegionMake(center, span);
	}
	return regionContainingData;
}

@end

/****************************************************************************/
#pragma mark -

@implementation  NSManagedObjectContext (AssociatedModel)
- (VelibModel *) model
{
    return (VelibModel*) self.coreDataManager;
}
@end
