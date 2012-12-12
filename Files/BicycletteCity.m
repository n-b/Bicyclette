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
#if TARGET_OS_IPHONE
#import "Radar.h"
#import "LocalUpdateQueue.h"
#endif

/****************************************************************************/
#pragma mark -

@interface BicycletteCity () <DataUpdaterDelegate>
@property DataUpdater * updater;
#if TARGET_OS_IPHONE
@property (nonatomic, readwrite) MKCoordinateRegion regionContainingData;
#endif
@end

/****************************************************************************/
#pragma mark -

@implementation BicycletteCity

- (id)initWithModelName:(NSString *)modelName storeURL:(NSURL *)storeURL
{
    return [super initWithModelName:@"BicycletteCity" storeURL:storeURL];
}

/****************************************************************************/
#pragma mark Service Info

+ (NSDictionary*) citiesInfo
{
    static NSDictionary * s_citiesInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_citiesInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BicycletteCities" ofType:@"plist"]];
    });
    return s_citiesInfo;
}

- (NSDictionary*) serviceInfo
{
    return [[[self class] citiesInfo] objectForKey:NSStringFromClass([self class])];
}

- (CLRegion*) hardcodedLimits
{
    NSDictionary * limits = self.serviceInfo[@"limits"];
    return [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake([limits[@"latitude"] doubleValue],
                                                                                     [limits[@"longitude"] doubleValue])
                                                   radius:[limits[@"distance"] doubleValue] identifier:[self title]];
}

- (CLLocation *) location
{
    NSDictionary * limits = self.serviceInfo[@"limits"];
    return [[CLLocation alloc] initWithLatitude:[limits[@"latitude"] doubleValue] longitude:[limits[@"longitude"] doubleValue]];
}

/****************************************************************************/
#pragma mark Update

- (void) update
{
    if(self.updater==nil)
    {
        self.updater = [[DataUpdater alloc] initWithURLStrings:[self updateURLStrings] delegate:self];
    }
}

- (void) updaterDidStartRequest:(DataUpdater *)updater
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.updateBegan object:self];
}

- (void) updater:(DataUpdater *)updater didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.updateFailed object:self userInfo:@{BicycletteCityNotifications.keys.failureError : error}];
    self.updater = nil;
}

- (void) updater:(DataUpdater*)updater finishedWithNewDataChunks:(NSArray*)datas
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.updateGotNewData object:self];
    
    [self parseDataChunks:datas];
    self.updater = nil;
}

- (void) updaterDidFinishWithNoNewData:(DataUpdater *)updater
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.updateSucceeded object:self userInfo:@{BicycletteCityNotifications.keys.dataChanged : @(NO)}];
    self.updater = nil;
}

/****************************************************************************/
#pragma mark Fetch requests

- (Station*) stationWithNumber:(NSString*)number
{
    NSArray * stations = [Station fetchStationWithNumber:self.moc number:number];
    return [stations lastObject];
}

#if TARGET_OS_IPHONE
- (NSArray*) stationsWithinRegion:(MKCoordinateRegion)region
{
    NSArray * stations = [Station fetchStationsWithinRange:self.moc
                                               minLatitude:@(region.center.latitude - region.span.latitudeDelta/2)
                                               maxLatitude:@(region.center.latitude + region.span.latitudeDelta/2)
                                              minLongitude:@(region.center.longitude - region.span.longitudeDelta/2)
                                              maxLongitude:@(region.center.longitude + region.span.longitudeDelta/2)];
    stations = [stations sortedArrayByDistanceFromLocation:[[CLLocation alloc]initWithLatitude:region.center.latitude longitude:region.center.longitude]];
    return stations;
}

- (NSArray*) radars
{
    NSFetchRequest * radarsRequest = [NSFetchRequest fetchRequestWithEntityName:[Radar entityName]];
    return [self.moc executeFetchRequest:radarsRequest error:NULL];
}

#endif

/****************************************************************************/
#pragma mark Coordinates

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

@implementation NSManagedObject (AssociatedCity)
- (BicycletteCity *) city
{
    BicycletteCity * city = (BicycletteCity *)[self.managedObjectContext coreDataManager];
    return city;
}
@end

/****************************************************************************/
#pragma mark Constants

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
