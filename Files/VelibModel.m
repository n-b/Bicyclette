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
#if TARGET_OS_IPHONE
#import "Radar.h"
#endif
#import "NSArrayAdditions.h"
#import "NSStringAdditions.h"
#import "NSObject+KVCMapping.h"
#import "NSError+MultipleErrorsCombined.h"
#import "DataUpdater.h"
#if TARGET_OS_IPHONE
#import "RadarUpdateQueue.h"
#endif

/****************************************************************************/
#pragma mark Constants

const struct VelibModelNotifications VelibModelNotifications = {
    .updateBegan = @"VelibModelNotifications.updateBegan",
    .updateGotNewData = @"VelibModelNotifications.updateGotNewData",
    .updateSucceeded = @"VelibModelNotifications.updateSucceded",
    .updateFailed = @"VelibModelNotifications.updateFailed",
    .keys = {
        .dataChanged = @"VelibModelNotifications.keys.dataChanged",
        .failureError = @"VelibModelNotifications.keys.failureError",
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
#if TARGET_OS_IPHONE
@property RadarUpdateQueue * updaterQueue;
// -
#endif
// -
#if TARGET_OS_IPHONE
@property (nonatomic, readwrite) MKCoordinateRegion regionContainingData;
#endif
// -
@property (nonatomic, strong) NSMutableDictionary * parsing_regionsByCodePostal;
@property (nonatomic, strong) NSMutableArray * parsing_oldStations;
@end

/****************************************************************************/
#pragma mark -

@implementation VelibModel

- (id)initWithModelName:(NSString *)modelName storeURL:(NSURL *)storeURL
{
    self = [super initWithModelName:modelName storeURL:storeURL];
    if (self) {
#if TARGET_OS_IPHONE
        self.updaterQueue = [[RadarUpdateQueue alloc] initWithModel:self];
#endif
    }
    return self;
}

/****************************************************************************/
#pragma mark Hardcoded Fixes

- (NSString *) name
{
    return NSLocalizedString(@"Vélib", nil);
}

- (NSDictionary*) hardcodedFixes
{
    NSString * filename = ([[NSUserDefaults standardUserDefaults] boolForKey:@"DebugUseHardcodedErrors"] ?
                           @"VelibHardcodedDebugErrors" :
                           @"VelibHardcodedFixes");
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
}

- (NSDictionary*) stationsHardcodedFixes
{
	if(nil==_stationsHardcodedFixes)
		self.stationsHardcodedFixes = (self.hardcodedFixes)[@"stations"];

	return _stationsHardcodedFixes;
}

- (CLRegion*) hardcodedLimits
{
	if( nil==_hardcodedLimits )
	{
        NSDictionary * dict = (self.hardcodedFixes)[@"limits"];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([dict[@"latitude"] doubleValue], [dict[@"longitude"] doubleValue]);
        CLLocationDistance distance = [dict[@"distance"] doubleValue];
        self.hardcodedLimits = [[CLRegion alloc] initCircularRegionWithCenter:coord radius:distance identifier:self.name];
	}
	return _hardcodedLimits;
}

/****************************************************************************/
#pragma mark Update

- (void) update
{
    if(self.updater==nil)
    {
        self.updater = [[DataUpdater alloc] initWithDelegate:self];
    }
}

/****************************************************************************/
#pragma mark Updater Delegate

- (NSURL*) urlForUpdater:(DataUpdater *)updater
{
    return [NSURL URLWithString:kVelibStationsListURL];    
}
- (NSString*) knownDataSha1ForUpdater:(DataUpdater*)updater
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"DebugAlwaysDownloadStationList"])
        return @"";
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"Database_XML_SHA1"];
}

- (void) setUpdater:(DataUpdater*)updater knownDataSha1:(NSString*)sha1
{
    [[NSUserDefaults standardUserDefaults] setObject:sha1 forKey:@"Database_XML_SHA1"];
}

- (void) updaterDidStartRequest:(DataUpdater *)updater
{
    [[NSNotificationCenter defaultCenter] postNotificationName:VelibModelNotifications.updateBegan object:self];
}

- (void) updater:(DataUpdater *)updater didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:VelibModelNotifications.updateFailed object:self userInfo:@{VelibModelNotifications.keys.failureError : error}];
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
    
    // Validate all stations (and delete invalid) before computing coordinates
    NSError * validationErrors;
    for (Region *r in [self.parsing_regionsByCodePostal allValues]) {
        for (Station *s in [r.stations copy]) {
            if(![s validateForInsert:&validationErrors])
            {
                s.region = nil;
                [self.moc deleteObject:s];
            }
        }
    }
    
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
    if ([self save:&validationErrors])
    {
        NSMutableDictionary * userInfo = [@{VelibModelNotifications.keys.dataChanged : @(YES)} mutableCopy];
        if (validationErrors)
            userInfo[VelibModelNotifications.keys.saveErrors] = [validationErrors underlyingErrors];
        [[NSNotificationCenter defaultCenter] postNotificationName:VelibModelNotifications.updateSucceeded object:self
                                                          userInfo:userInfo];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VelibModelNotifications.updateFailed object:self
                                                          userInfo:
         @{VelibModelNotifications.keys.failureError : validationErrors}];
    }

    self.updater = nil;
}

- (void) updaterDidFinishWithNoNewData:(DataUpdater *)updater
{
    [[NSNotificationCenter defaultCenter] postNotificationName:VelibModelNotifications.updateSucceeded object:self userInfo:@{VelibModelNotifications.keys.dataChanged : @(NO)}];
    self.updater = nil;
}


/****************************************************************************/
#pragma mark Parser delegate

- (NSDictionary*) stationKVCMapping
{
    static NSDictionary * s_mapping = nil;
    if(nil==s_mapping)
        s_mapping = @{
        @"address" : @"address",
        @"bonus" : @"bonus",
        @"fullAddress" : @"fullAddress",
        @"name" : @"name",
        @"number" : @"number",
        @"open" : @"open",
        
        @"lat" : @"latitude",
        @"lng" : @"longitude"
        };
    
    return s_mapping;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"marker"])
	{
        // Filter out closed stations
        if( ! [attributeDict[@"open"] boolValue] )
        {
            NSLog(@"Note : Ignored closed station : %@", attributeDict);
            return;
        }
        
        // Find Existing Stations
        Station * station = [self.parsing_oldStations firstObjectWithValue:attributeDict[@"number"] forKey:StationAttributes.number];
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
		NSDictionary * fixes = (self.stationsHardcodedFixes)[station.number];
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
                        lCodePostal = fixes[@"codePostal"];
                        if(nil==lCodePostal)		// Dernier recours
                            lCodePostal = @"75000";
                        break;
                }
                
                NSLog(@"Note : Used heuristics to find region for %@. Found : %@. ",attributeDict, lCodePostal);
            }
            NSAssert1([lCodePostal rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound,@"codePostal %@ contient des caractères invalides",lCodePostal);
            
            // Keep regions in an array locally, to avoid fetching a Region for every Station parsed.
            Region * region = (self.parsing_regionsByCodePostal)[lCodePostal];
            if(nil==region)
            {
                region = [[Region fetchRegionWithNumber:self.moc number:lCodePostal] lastObject];
                if(region==nil)
                {
                    region = [Region insertInManagedObjectContext:self.moc];
                    region.number = lCodePostal;
                }
                (self.parsing_regionsByCodePostal)[lCodePostal] = region;
                if([lCodePostal hasPrefix:@"75"])
                    region.name = [NSString stringWithFormat:@"Paris %@",[[lCodePostal substringFromIndex:3] stringByDeletingPrefix:@"0"]];
                else
                {
                    NSString * cityName = [[[endOfAddress stringByDeletingPrefix:region.number]
                                            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                                           capitalizedString];
                    region.name = cityName;
                }
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

#if TARGET_OS_IPHONE
- (Radar *) userLocationRadar
{
    Radar * r = [[Radar fetchUserLocationRadar:self.moc] lastObject];
    if(r==nil)
    {
        r = [Radar insertInManagedObjectContext:self.moc];
        r.manualRadarValue = NO;
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
        r.manualRadarValue = NO;
        r.identifier = RadarIdentifiers.screenCenter;
        [self save:nil];
    }
    return r;
}
#endif

- (Station*) stationWithNumber:(NSString*)number
{
    NSArray * stations = [Station fetchStationWithNumber:self.moc number:number];
    return [stations lastObject];
}

/****************************************************************************/
#pragma mark Coordinates

- (NSString *) title
{
    return self.name;
}

#if TARGET_OS_IPHONE
- (CLLocationCoordinate2D) coordinate
{
    return self.regionContainingData.center;
}

- (MKCoordinateRegion) regionContainingData
{
	if(_regionContainingData.center.latitude == 0 &&
	   _regionContainingData.center.longitude == 0 &&
	   _regionContainingData.span.latitudeDelta == 0 &&
	   _regionContainingData.span.longitudeDelta == 0 )
	{
		NSFetchRequest * regionsRequest = [NSFetchRequest new];
		[regionsRequest setEntity:[Region entityInManagedObjectContext:self.moc]];
		NSError * requestError = nil;
		NSArray * regions = [self.moc executeFetchRequest:regionsRequest error:&requestError];
        if([regions count]==0)
        {
            CLRegion * limits = [self hardcodedLimits];
            return MKCoordinateRegionMakeWithDistance(limits.center, limits.radius*2, limits.radius*2);
        }
        
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
	return _regionContainingData;
}
#endif

@end

/****************************************************************************/
#pragma mark -

@implementation  NSManagedObjectContext (AssociatedModel)
- (VelibModel *) model
{
    return (VelibModel*) self.coreDataManager;
}
@end
