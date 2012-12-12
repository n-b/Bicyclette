//
//  CitiesController.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 07/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CitiesController.h"
#import "BicycletteCity.h"
#import "Station.h"
#import "Region.h"
#import "Radar.h"
#import "CollectionsAdditions.h"

#import "LocalUpdateQueue.h"
#import "CityRegionUpdateGroup.h"
#import "GeoFencesMonitor.h"

#import "ParisVelibCity.h"
#import "MarseilleLeVeloCity.h"
#import "ToulouseVeloCity.h"
#import "AmiensVelamCity.h"

#import "UIApplication+LocalAlerts.h"

typedef enum {
	MapLevelNone = 0,
	MapLevelRegions,
	MapLevelRegionsAndRadars,
	MapLevelStationsAndRadars
}  MapLevel;


@interface CitiesController () <CLLocationManagerDelegate, LocalUpdateQueueDelegate, GeoFencesMonitorDelegate>
@property GeoFencesMonitor * fenceMonitor;
@property LocalUpdateQueue * updateQueue;
@property MapLevel level;
@property CityRegionUpdateGroup * userLocationUpdateGroup;
@property CityRegionUpdateGroup * screenCenterUpdateGroup;
@end

/****************************************************************************/
#pragma mark -

@implementation CitiesController

- (id)init
{
    self = [super init];
    if (self) {
        // Create city
        self.cities = (@[[ParisVelibCity new],
                       [MarseilleLeVeloCity new],
                       [ToulouseVeloCity new],
                       [AmiensVelamCity new] ]);

        self.fenceMonitor = [GeoFencesMonitor new];
        self.fenceMonitor.delegate = self;
        self.updateQueue = [LocalUpdateQueue new];
        self.updateQueue.delayBetweenPointUpdates = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DataUpdaterDelayBetweenQueues"];
        self.updateQueue.moniteredGroupsMaximumDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"MaxRefreshDistance"];
        self.updateQueue.delegate = self;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityUpdated:)
                                                     name:BicycletteCityNotifications.updateSucceeded object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStateChanged:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStateChanged:) name:UIApplicationDidEnterBackgroundNotification object:nil];

        self.userLocationUpdateGroup = [CityRegionUpdateGroup new];
        self.screenCenterUpdateGroup = [CityRegionUpdateGroup new];
        [self.updateQueue addMonitoredGroup:self.userLocationUpdateGroup];
        [self.updateQueue addMonitoredGroup:self.screenCenterUpdateGroup];

    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) reloadData
{
    if(self.currentCity)
        self.referenceRegion = self.currentCity.regionContainingData;
    else
    {
        NSDictionary * dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"BicycletteLimits"];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([dict[@"latitude"] doubleValue], [dict[@"longitude"] doubleValue]);
        MKCoordinateSpan span = MKCoordinateSpanMake([dict[@"latitudeDelta"] doubleValue], [dict[@"longitudeDelta"] doubleValue]);
        self.referenceRegion = MKCoordinateRegionMake(coord, span);
    }
    
    MKCoordinateRegion region = self.referenceRegion;
    // zoom in a little
    region.span.latitudeDelta /= 2;
    region.span.longitudeDelta /= 2;
	[self.delegate controller:self setRegion:region];
    
    [self addAndRemoveMapAnnotations];
}

- (void) setCurrentCity:(BicycletteCity *)currentCity_
{
    if(_currentCity != currentCity_)
    {
        for (Radar * radar in [_currentCity radars]) {
            [self.updateQueue removeMonitoredGroup:radar];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:self.currentCity];
        
        _currentCity = currentCity_;
        for (Radar * radar in [_currentCity radars]) {
            [self.fenceMonitor addFence:radar];
            [self.updateQueue addMonitoredGroup:radar];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsChanged:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification object:self.currentCity.moc];
        
        NSLog(@"city changed to %@",_currentCity.name);
        self.screenCenterUpdateGroup.city = _currentCity;
        self.userLocationUpdateGroup.city = _currentCity;
    }
}

- (void) regionDidChange:(MKCoordinateRegion)viewRegion
{
    // Compute coordinates
    // center
    CLLocationCoordinate2D centerCoord = viewRegion.center;
    CLLocation * center = [[CLLocation alloc] initWithLatitude:centerCoord.latitude longitude:centerCoord.longitude];

    // bounds
    CLLocation * northLocation = [[CLLocation alloc] initWithLatitude:viewRegion.center.latitude+viewRegion.span.latitudeDelta longitude:viewRegion.center.longitude/2];
    CLLocation * southLocation = [[CLLocation alloc] initWithLatitude:viewRegion.center.latitude-viewRegion.span.latitudeDelta longitude:viewRegion.center.longitude/2];
    CLLocation * westLocation = [[CLLocation alloc] initWithLatitude:viewRegion.center.latitude longitude:viewRegion.center.latitude-viewRegion.span.longitudeDelta/2];
    CLLocation * eastLocation = [[CLLocation alloc] initWithLatitude:viewRegion.center.latitude longitude:viewRegion.center.latitude+viewRegion.span.longitudeDelta/2];
    CLLocationDistance latDistance = [northLocation distanceFromLocation:southLocation];
    CLLocationDistance longDistance = [eastLocation distanceFromLocation:westLocation];
    CLLocationDistance avgDistance = (latDistance+longDistance)/2;

    // Change level according to bounds
    if(avgDistance > [[NSUserDefaults standardUserDefaults] doubleForKey:@"MapLevelRegions"])
		self.level = MapLevelNone;
	else if(avgDistance > [[NSUserDefaults standardUserDefaults] doubleForKey:@"MapLevelRegionsAndRadars"])
		self.level = MapLevelRegions;
    else if(avgDistance > [[NSUserDefaults standardUserDefaults] doubleForKey:@"MapLevelStationsAndRadars"])
		self.level = MapLevelRegionsAndRadars;
	else
		self.level = MapLevelStationsAndRadars;
    
    // Change to nearest city
    if(self.level == MapLevelNone)
        self.currentCity = nil;
    else
        self.currentCity = [self.cities sortedArrayByDistanceFromLocation:center][0];

    // Update annotations
    [self addAndRemoveMapAnnotations];

    // Keep the screen center Radar centered
    // And make it as big as the screen, but only if the stations are actually visible
    if(self.level==MapLevelStationsAndRadars)
        [self.screenCenterUpdateGroup setRegion:[self.delegate regionForController:self]];
    else
        [self.screenCenterUpdateGroup setRegion:
         MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(0, 0), 0, 0)];
    
    // In the same vein, only set the updater reference location if we're down enough
    if(self.level==MapLevelRegionsAndRadars || self.level==MapLevelStationsAndRadars)
    {
        self.updateQueue.referenceLocation = center;
        CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadarDistance"];
        [self.userLocationUpdateGroup setRegion:MKCoordinateRegionMakeWithDistance(center.coordinate,
                                                                                   distance, distance)];
    }
    else
        self.updateQueue.referenceLocation = nil;
}


- (void) addAndRemoveMapAnnotations
{
    NSMutableArray * newAnnotations = [NSMutableArray new];
    
    if (self.level == MapLevelNone)
    {
        // City
        [newAnnotations addObjectsFromArray:self.cities];
    }
    
    if (self.level == MapLevelRegions || self.level == MapLevelRegionsAndRadars)
    {
        // Regions
        NSFetchRequest * regionsRequest = [NSFetchRequest fetchRequestWithEntityName:[Region entityName]];
        [newAnnotations addObjectsFromArray:[self.currentCity.moc executeFetchRequest:regionsRequest error:NULL]];
    }
    
    if (self.level == MapLevelRegionsAndRadars || self.level == MapLevelStationsAndRadars)
    {
        // Radars
        NSFetchRequest * radarsRequest = [NSFetchRequest fetchRequestWithEntityName:[Radar entityName]];
        NSArray * radars = [self.currentCity.moc executeFetchRequest:radarsRequest error:NULL];
        [newAnnotations addObjectsFromArray:[newAnnotations arrayByAddingObjectsFromArray:radars]];
    }
    
    if (self.level == MapLevelStationsAndRadars)
    {
        // Stations
        NSFetchRequest * stationsRequest = [NSFetchRequest new];
		[stationsRequest setEntity:[Station entityInManagedObjectContext:self.currentCity.moc]];
        MKCoordinateRegion mapRegion = [self.delegate regionForController:self];
		stationsRequest.predicate = [NSPredicate predicateWithFormat:@"latitude>%f AND latitude<%f AND longitude>%f AND longitude<%f",
                                     mapRegion.center.latitude - mapRegion.span.latitudeDelta/2,
                                     mapRegion.center.latitude + mapRegion.span.latitudeDelta/2,
                                     mapRegion.center.longitude - mapRegion.span.longitudeDelta/2,
                                     mapRegion.center.longitude + mapRegion.span.longitudeDelta/2];
        [newAnnotations addObjectsFromArray:[self.currentCity.moc executeFetchRequest:stationsRequest error:NULL]];
    }
    
    [self.delegate controller:self setAnnotations:newAnnotations];
}

/****************************************************************************/
#pragma mark -

- (void) appStateChanged:(NSNotification*)note
{
    self.updateQueue.monitoringPaused = [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
}

/****************************************************************************/
#pragma mark -

- (void) monitor:(GeoFencesMonitor*)monitor fenceWasEntered:(Radar*)radar
{
    [self.updateQueue addOneshotGroup:radar];
}

- (void) monitor:(GeoFencesMonitor*)monitor fenceWasExited:(Radar*)radar
{
    [self.updateQueue removeOneshotGroup:radar];
}

/****************************************************************************/
#pragma mark -

- (void) updateQueue:(LocalUpdateQueue *)queue didUpdateOneshotPoint:(Station*)station ofGroup:(Radar*)radar
{
    NSAssert([station isKindOfClass:[Station class]],nil);
    NSAssert([radar isKindOfClass:[Radar class]],nil);
    [[UIApplication sharedApplication] presentLocalNotificationMessage:station.localizedSummary userInfo:(@{@"city": NSStringFromClass([station.city class]) ,
                                                                                                          @"stationNumber": station.number})];
}

/****************************************************************************/
#pragma mark -

- (void) cityUpdated:(NSNotification*) note
{
    if([note.userInfo[BicycletteCityNotifications.keys.dataChanged] boolValue])
        [self reloadData];
}

/****************************************************************************/
#pragma mark -

- (void) objectsChanged:(NSNotification*)note
{
    for (id object in note.userInfo[NSInsertedObjectsKey]) {
        if([object conformsToProtocol:@protocol(GeoFence)])
            [self.fenceMonitor addFence:object];
        if([object conformsToProtocol:@protocol(LocalUpdateGroup)])
            [self.updateQueue addMonitoredGroup:object];
    }

    for (id object in note.userInfo[NSDeletedObjectsKey]) {
        if([object conformsToProtocol:@protocol(GeoFence)])
            [self.fenceMonitor removeFence:object];
        if([object conformsToProtocol:@protocol(LocalUpdateGroup)])
            [self.updateQueue removeMonitoredGroup:object];
    }
}

/****************************************************************************/
#pragma mark -

- (void) handleLocalNotificaion:(UILocalNotification*)notification
{
    NSString * cityClassName = notification.userInfo[@"city"];
    BicycletteCity * city;
    for (BicycletteCity * aCity in self.cities) {
        if([NSStringFromClass([aCity class]) isEqualToString:cityClassName])
        {
            city = aCity;
            break;
        }
    }
    NSString * number = notification.userInfo[@"stationNumber"];
    Station * station = nil;
    if(number)
    {
        station = [city stationWithNumber:number];
    }

    if(city && number)
    {
        self.currentCity = city;
        CLLocationDistance meters = [[NSUserDefaults standardUserDefaults] doubleForKey:@"MapRegionZoomDistance"];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(station.coordinate, meters, meters);
        [self.delegate controller:self setRegion:region];
        [self.delegate controller:self selectAnnotation:station];
    }
}

@end
