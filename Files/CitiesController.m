//
//  CitiesController.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 07/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CitiesController.h"
#import "BicycletteCity.h"
#import "BicycletteCity.mogenerated.h"
#import "CollectionsAdditions.h"
#import "LocalUpdateQueue.h"
#import "CityRegionUpdateGroup.h"
#import "GeoFencesMonitor.h"
#import "UIApplication+LocalAlerts.h"

@interface CitiesController () <CLLocationManagerDelegate, LocalUpdateQueueDelegate, GeoFencesMonitorDelegate>
@property GeoFencesMonitor * fenceMonitor;
@property LocalUpdateQueue * updateQueue;

@property CityRegionUpdateGroup * userLocationUpdateGroup;
@property CityRegionUpdateGroup * screenCenterUpdateGroup;

@property MKCoordinateRegion viewRegion;
@end

/****************************************************************************/
#pragma mark -

@implementation CitiesController

- (id)init
{
    self = [super init];
    if (self) {
        // Create cities
        BicycletteCitySetSaveStationsWithNoIndividualStatonUpdates(YES);
        BicycletteCitySetStoresDirectory([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]);
        self.cities = [_BicycletteCity allCities];

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

    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
                                                     name:NSManagedObjectContextObjectsDidChangeNotification object:self.currentCity.mainContext];

        self.screenCenterUpdateGroup.city = _currentCity;
        self.userLocationUpdateGroup.city = _currentCity;

        if( ! [[_currentCity class] canUpdateIndividualStations])
            [_currentCity update];
    }
}

- (CLLocationDistance) regionSpanMeters
{
    CLLocation * northLocation = [[CLLocation alloc] initWithLatitude:self.viewRegion.center.latitude+self.viewRegion.span.latitudeDelta/2 longitude:self.viewRegion.center.longitude];
    CLLocation * southLocation = [[CLLocation alloc] initWithLatitude:self.viewRegion.center.latitude-self.viewRegion.span.latitudeDelta/2 longitude:self.viewRegion.center.longitude];
    CLLocation * westLocation = [[CLLocation alloc] initWithLatitude:self.viewRegion.center.latitude longitude:self.viewRegion.center.latitude-self.viewRegion.span.longitudeDelta/2];
    CLLocation * eastLocation = [[CLLocation alloc] initWithLatitude:self.viewRegion.center.latitude longitude:self.viewRegion.center.latitude+self.viewRegion.span.longitudeDelta/2];
    CLLocationDistance viewSpanMeters = ([northLocation distanceFromLocation:southLocation]+[eastLocation distanceFromLocation:westLocation])/2;
    return viewSpanMeters;
}

- (BOOL) showCurrentCityStations
{
    if(nil==self.currentCity)
        return NO;
    if(![self.currentCity hasRegions])
        return YES;
    else
        return [self regionSpanMeters] < [self.currentCity radius] * [[NSUserDefaults standardUserDefaults] doubleForKey:@"CitiesController.CurrentCityZoomThreshold"] / 2;
}

- (void) regionDidChange:(MKCoordinateRegion)viewRegion
{
    self.viewRegion = viewRegion;
    
    // center & span
    CLLocation * center = [[CLLocation alloc] initWithLatitude:self.viewRegion.center.latitude longitude:self.viewRegion.center.longitude];
    CLLocationDistance viewSpanMeters = [self regionSpanMeters];

    // Get the nearest city
    BicycletteCity * nearestCity = nil;
    nearestCity = (BicycletteCity*)[self.cities nearestLocatableFrom:center];
    CLLocationDistance distanceToCity = [nearestCity.location distanceFromLocation:center];
    
    // Are we actually near from the city ?
    if(distanceToCity > [nearestCity radius] * [[NSUserDefaults standardUserDefaults] doubleForKey:@"CitiesController.CurrentCityDistanceThreshold"])
        nearestCity = nil;

    // Are we zooming enough ?
    if(viewSpanMeters > [nearestCity radius] * [[NSUserDefaults standardUserDefaults] doubleForKey:@"CitiesController.CurrentCityZoomThreshold"])
        nearestCity = nil;
    
    if(self.currentCity!=nearestCity)
        self.currentCity = nearestCity;

    // Update annotations
    [self addAndRemoveMapAnnotations];

    // Keep the screen center Radar centered
    // And make it as big as the screen, but only if the stations are actually visible
    [self.screenCenterUpdateGroup setRegion:self.viewRegion];
    
    // In the same vein, only set the updater reference location if we're down enough
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadarDistance"];
    [self.userLocationUpdateGroup setRegion:MKCoordinateRegionMakeWithDistance(self.viewRegion.center, distance, distance)];

    if([self showCurrentCityStations])
    {
        [self.updateQueue addMonitoredGroup:self.screenCenterUpdateGroup];
        [self.updateQueue addMonitoredGroup:self.userLocationUpdateGroup];
    }
    else
    {
        [self.updateQueue removeMonitoredGroup:self.screenCenterUpdateGroup];
        [self.updateQueue removeMonitoredGroup:self.userLocationUpdateGroup];
    }

    if(self.currentCity)
        self.updateQueue.referenceLocation = center;
    else
        self.updateQueue.referenceLocation = nil;
}

- (void) addAndRemoveMapAnnotations
{
    NSMutableArray * newAnnotations = [NSMutableArray new];
    
    if (self.currentCity==nil)
    {
        // World Cities
        [newAnnotations addObjectsFromArray:self.cities];
    }
    else
    {
        // Radars
        NSFetchRequest * radarsRequest = [NSFetchRequest fetchRequestWithEntityName:[Radar entityName]];
        NSArray * radars = [self.currentCity.mainContext executeFetchRequest:radarsRequest error:NULL];
        [newAnnotations addObjectsFromArray:[newAnnotations arrayByAddingObjectsFromArray:radars]];

        // Stations
        if([self showCurrentCityStations])
        {
            MKCoordinateRegion mapRegion = self.viewRegion;
            mapRegion.span.latitudeDelta *= 1.25; // Add stations that are just off screen limits
            mapRegion.span.longitudeDelta *= 1.25;
            [newAnnotations addObjectsFromArray:[self.currentCity stationsWithinRegion:mapRegion]];
        }
        else // Regions
        {
            NSAssert([self.currentCity hasRegions], nil);
            // Regions
            NSFetchRequest * regionsRequest = [NSFetchRequest fetchRequestWithEntityName:[Region entityName]];
            [newAnnotations addObjectsFromArray:[self.currentCity.mainContext executeFetchRequest:regionsRequest error:NULL]];
        }
    }

    [self.delegate controller:self setAnnotations:newAnnotations];
}

/****************************************************************************/
#pragma mark -

- (void) appStateChanged:(NSNotification*)note
{
    if([note.name isEqualToString:UIApplicationDidEnterBackgroundNotification])
        self.updateQueue.monitoringPaused = YES;
    else if([note.name isEqualToString:UIApplicationWillEnterForegroundNotification])
        self.updateQueue.monitoringPaused = NO;
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
        [self addAndRemoveMapAnnotations];
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
