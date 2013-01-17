//
//  BicycletteCity.m
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"
#import "BicycletteCity+Update.h"
#if TARGET_OS_IPHONE
#import "LocalUpdateQueue.h"
#endif

@interface BicycletteCity ()
@property NSDictionary* serviceInfo;
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

@implementation BicycletteCity

- (NSString*) storePathForName:(NSString*)storeName
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
- (NSString *) cityGroup { return _serviceInfo[@"city_group"]; }
- (BOOL) isMainCityGroup {
    return [self.cityGroup length]==0 || [self.cityName isEqualToString:self.cityGroup];
}
- (NSString *) serviceName { return _serviceInfo[@"service_name"]; }
- (NSDictionary*) patches { return self.serviceInfo[@"patches"]; }

- (NSDictionary*) prefs { return self.serviceInfo[@"prefs"]; }
- (id) prefForKey:(NSString*)key
{
    id res = [self prefs][key];
    if(res)
        return res;
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (CLRegion *) knownRegion
{
    return [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake([self.serviceInfo[@"latitude"] doubleValue],
                                                                                     [self.serviceInfo[@"longitude"] doubleValue])
                                                   radius:[self.serviceInfo[@"radius"] doubleValue] identifier:[self title]];
}

- (CLRegion*) regionContainingData
{
	if(nil==_regionContainingData)
	{
        if( ![self isStoreLoaded] )
            return [self knownRegion];
        
        NSFetchRequest * stationsRequest = [[NSFetchRequest alloc] initWithEntityName:[Station entityName]];
		NSError * requestError = nil;
		NSArray * stations = [self.mainContext executeFetchRequest:stationsRequest error:&requestError];
        if([stations count]==0)
            return [self knownRegion];
        
        CLLocationDegrees maxLatitude = [[stations valueForKeyPath:@"@max.latitude"] doubleValue];
        CLLocationDegrees minLatitude = [[stations valueForKeyPath:@"@min.latitude"] doubleValue];
        CLLocationDegrees maxLongitude = [[stations valueForKeyPath:@"@max.longitude"] doubleValue];
        CLLocationDegrees minLongitude = [[stations valueForKeyPath:@"@min.longitude"] doubleValue];
        CLLocation * dataCenter = [[CLLocation alloc] initWithLatitude:(minLatitude+maxLatitude)/2.0
                                                             longitude:(minLongitude+maxLongitude)/2.0];
        
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

- (BOOL) hasRegions
{
    return [self respondsToSelector:@selector(regionInfoFromStation:values:patchs:requestURL:)];
}

#pragma mark Fetch requests

- (Station*) stationWithNumber:(NSString*)number
{
    NSArray * stations = [Station fetchStationWithNumber:self.mainContext number:number];
    return [stations lastObject];
}

#if TARGET_OS_IPHONE
- (NSArray*) radars
{
    NSFetchRequest * radarsRequest = [NSFetchRequest fetchRequestWithEntityName:[Radar entityName]];
    return [self.mainContext executeFetchRequest:radarsRequest error:NULL];
}

- (NSArray*) stationsWithinRegion:(MKCoordinateRegion)region
{
    NSArray * stations = [Station fetchStationsWithinRange:self.mainContext
                                               minLatitude:@(region.center.latitude - region.span.latitudeDelta/2)
                                               maxLatitude:@(region.center.latitude + region.span.latitudeDelta/2)
                                              minLongitude:@(region.center.longitude - region.span.longitudeDelta/2)
                                              maxLongitude:@(region.center.longitude + region.span.longitudeDelta/2)];
    return stations;
}
#endif


#pragma mark Annotations

- (NSString *) title { return [NSString stringWithFormat:@"%@ %@",[self cityName],[self serviceName]]; }
- (NSString *) titleForStation:(Station *)station { return station.name; }
- (NSString *) subtitleForStation:(Station *)station {
    return station.openValue ? nil : NSLocalizedString(@"STATION_STATUS_CLOSED", nil);
}
- (NSString *) titleForRegion:(Region*)region { return region.name; }
- (NSString *) subtitleForRegion:(Region*)region { return @""; }

@end

/****************************************************************************/
#pragma mark -

@implementation NSManagedObject (BicycletteCity)
- (BicycletteCity *) city
{
    BicycletteCity * city = (BicycletteCity *)[self.managedObjectContext coreDataManager];
    return city;
}
@end

/****************************************************************************/
#pragma mark - Update Notifications

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
