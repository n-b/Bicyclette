//
//  BicycletteCity.m
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"
#import "Station.h"
#import "Region.h"
#import "NSStringAdditions.h"
#import "DataUpdater.h"
#import "NSError+MultipleErrorsCombined.h"
#if TARGET_OS_IPHONE
#import "Radar.h"
#import "LocalUpdateQueue.h"
#endif

// Allow me to use method implemented in subclasses
@interface _BicycletteCity (BicycletteCity) <BicycletteCity>
@end

@interface _BicycletteCity () <DataUpdaterDelegate>
@property NSDictionary* serviceInfo;
@property DataUpdater * updater;
@property (nonatomic, readwrite) CLRegion * regionContainingData;
@end

#pragma mark -

void BicycletteCitySetStoresDirectory(NSString* directory)
{
    [[NSUserDefaults standardUserDefaults] setObject:directory forKey:@"BicycletteStoresDirectory"];
}

static NSString* BicycletteCityStoresDirectory(void)
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"BicycletteStoresDirectory"];
}

void BicycletteCitySetSaveStationsWithNoIndividualStatonUpdates(BOOL save)
{
    [[NSUserDefaults standardUserDefaults] setBool:save forKey:@"BicycletteSaveStationsWithNoIndividualStatonUpdates"];
}

static BOOL BicycletteCitySaveStationsWithNoIndividualStatonUpdates(void)
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteSaveStationsWithNoIndividualStatonUpdates"];
}

@implementation _BicycletteCity

+ (NSString*) storePathForName:(NSString*)storeName
{
    if(!BicycletteCitySaveStationsWithNoIndividualStatonUpdates() && ![self canUpdateIndividualStations])
        return nil;

    return [BicycletteCityStoresDirectory() stringByAppendingPathComponent:storeName];
}

+ (NSArray*) allCities
{
    NSData * data = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"BicycletteCities" ofType:@"json"]];
    NSError * error;
    NSArray * serviceInfoArrays = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSAssert(serviceInfoArrays!=nil, @"BicycletteCities JSON error: %@", error);
    NSMutableArray * cities = [NSMutableArray new];
    for (NSDictionary * serviceInfo in serviceInfoArrays) {
        [cities addObject:[self cityWithServiceInfo:serviceInfo]];
    }
    return cities;
}

+ (instancetype) cityWithServiceInfo:(NSDictionary*)serviceInfo_
{
    Class cityClass = NSClassFromString(serviceInfo_[@"city_class"]);
    NSAssert([cityClass isSubclassOfClass:self], nil);
    return [[cityClass alloc] initWithServiceInfo:serviceInfo_];
}

- (id) initWithServiceInfo:(NSDictionary*)serviceInfo_
{
    self = [super initWithStoreName:[NSString stringWithFormat:@"%@_%@.coredata",serviceInfo_[@"city_name"], serviceInfo_[@"service_name"]]];
    if(self!=nil)
    {
        self.serviceInfo = serviceInfo_;
    }
    return self;
}

#pragma mark General properties

- (NSString *) cityName { return _serviceInfo[@"city_name"]; }
- (NSString *) serviceName { return _serviceInfo[@"service_name"]; }
- (NSArray *) updateURLStrings { return @[_serviceInfo[@"update_url"]]; }
- (NSString *) detailsURLStringForStation:(Station*)station { return [self.serviceInfo[@"station_details_url"] stringByAppendingString:station.number]; }

- (CLRegion *) hardcodedLimits
{
    return [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake([self.serviceInfo[@"latitude"] doubleValue],
                                                                                     [self.serviceInfo[@"longitude"] doubleValue])
                                                   radius:[self.serviceInfo[@"radius"] doubleValue] identifier:[self title]];
}

- (CLRegion*) regionContainingData
{
	if(nil==_regionContainingData)
	{
        NSFetchRequest * stationsRequest = [[NSFetchRequest alloc] initWithEntityName:[Station entityName]];
		NSError * requestError = nil;
		NSArray * stations = [self.moc executeFetchRequest:stationsRequest error:&requestError];
        if([stations count]==0)
            return [self hardcodedLimits];
        
        CLLocation * dataCenter = [[CLLocation alloc] initWithLatitude:[[stations valueForKeyPath:@"@avg.latitude"] doubleValue] longitude:[[stations valueForKeyPath:@"@avg.longitude"] doubleValue]];

        CLLocationDistance distanceMax = 0;
        for (Station * station in stations)
            distanceMax = MAX(distanceMax, [station.location distanceFromLocation:dataCenter]);

		self.regionContainingData = [[CLRegion alloc] initCircularRegionWithCenter:dataCenter.coordinate
                                                                            radius:distanceMax
                                                                        identifier:[self title]];
	}
	return _regionContainingData;
}

- (CLLocation *) location
{
    return [[CLLocation alloc] initWithLatitude:self.regionContainingData.center.latitude longitude:self.regionContainingData.center.longitude];
}

- (CLLocationDistance) radius
{
    return self.regionContainingData.radius;
}

- (CLLocationCoordinate2D) coordinate
{
    return self.regionContainingData.center;
}

#pragma mark Fetch requests

- (Station*) stationWithNumber:(NSString*)number
{
    NSArray * stations = [Station fetchStationWithNumber:self.moc number:number];
    return [stations lastObject];
}

#if TARGET_OS_IPHONE
- (NSArray*) radars
{
    NSFetchRequest * radarsRequest = [NSFetchRequest fetchRequestWithEntityName:[Radar entityName]];
    return [self.moc executeFetchRequest:radarsRequest error:NULL];
}

- (NSArray*) stationsWithinRegion:(MKCoordinateRegion)region
{
    NSArray * stations = [Station fetchStationsWithinRange:self.moc
                                               minLatitude:@(region.center.latitude - region.span.latitudeDelta/2)
                                               maxLatitude:@(region.center.latitude + region.span.latitudeDelta/2)
                                              minLongitude:@(region.center.longitude - region.span.longitudeDelta/2)
                                              maxLongitude:@(region.center.longitude + region.span.longitudeDelta/2)];
    return stations;
}
#endif

#pragma mark Data Updates

- (void) update
{
    if(self.updater==nil)
    {
        self.updater = [[DataUpdater alloc] initWithURLStrings:[self updateURLStrings] delegate:self];
        [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:BicycletteCityNotifications.updateBegan object:self]
                                                   postingStyle:NSPostASAP];
    }
}

- (void) updater:(DataUpdater *)updater didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.updateFailed object:self userInfo:@{BicycletteCityNotifications.keys.failureError : error}];
    self.updater = nil;
}

- (void) updaterDidFinishWithNoNewData:(DataUpdater *)updater
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.updateSucceeded object:self userInfo:@{BicycletteCityNotifications.keys.dataChanged : @(NO)}];
    self.updater = nil;
}

- (void) updater:(DataUpdater*)updater finishedWithNewDataChunks:(NSDictionary*)datas
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.updateGotNewData object:self];
    
    __block NSError * validationErrors;
    [self performUpdates:^(NSManagedObjectContext *updateContext) {
        // Get Old Stations Names
        NSError * requestError = nil;
        
        NSFetchRequest * oldStationsRequest = [NSFetchRequest fetchRequestWithEntityName:[Station entityName]];
        NSMutableArray* oldStations =  [[updateContext executeFetchRequest:oldStationsRequest error:&requestError] mutableCopy];
        
        // Parsing
        for (NSString * urlString in datas) {
            [self parseData:datas[urlString]
              fromURLString:urlString
                  inContext:updateContext
                oldStations:oldStations];
        }
        
        // Post processing :
        // Validate all stations (and delete invalid) before computing coordinates
        NSFetchRequest * allRegionsRequest = [NSFetchRequest fetchRequestWithEntityName:[Region entityName]];
        NSArray * regions = [updateContext executeFetchRequest:allRegionsRequest error:&requestError];
        for (Region *r in regions) {
            for (Station *s in [r.stations copy]) {
                if(![s validateForInsert:&validationErrors])
                {
                    s.region = nil;
                    [updateContext deleteObject:s];
                }
            }
            [r setupCoordinates];
        }
                
        // Delete Old Stations
        for (Station * oldStation in oldStations) {
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteLogParsingDetails"])
                NSLog(@"Note : old station deleted after update : %@", oldStation);
            [updateContext deleteObject:oldStation];
        }
        
    } saveCompletion:^(NSNotification *contextDidSaveNotification) {
        NSMutableDictionary * userInfo = [@{BicycletteCityNotifications.keys.dataChanged : @(YES)} mutableCopy];
        if (validationErrors)
            userInfo[BicycletteCityNotifications.keys.saveErrors] = [validationErrors underlyingErrors];
        [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.updateSucceeded object:self
                                                          userInfo:userInfo];
    }];
    self.updater = nil;
}

+ (BOOL) canUpdateIndividualStations
{
    return [self instancesRespondToSelector:@selector(parseData:forStation:)];
}

#pragma mark Annotations

- (NSString*) title { return [NSString stringWithFormat:@"%@ %@",[self cityName],[self serviceName]]; }
- (NSString *) titleForStation:(Station *)station { return station.name; }

@end

#pragma mark -

@implementation NSManagedObject (BicycletteCity)
- (BicycletteCity *) city
{
    BicycletteCity * city = (BicycletteCity *)[self.managedObjectContext coreDataManager];
    return city;
}
@end

#pragma mark Update Notifications

const struct BicycletteCityNotifications BicycletteCityNotifications = {
    .canRequestLocation = @"BicycletteCityNotifications.canRequestLocation",
    .updateBegan = @"BicycletteCityNotifications.updateBegan",
    .updateGotNewData = @"BicycletteCityNotifications.updateGotNewData",
    .updateSucceeded = @"BicycletteCityNotifications.updateSucceded",
    .updateFailed = @"BicycletteCityNotifications.updateFailed",
    .keys = {
        .dataChanged = @"BicycletteCityNotifications.keys.dataChanged",
        .failureError = @"BicycletteCityNotifications.keys.failureError",
        .saveErrors = @"BicycletteCityNotifications.keys.saveErrors",
    }
};
