//
//  CitiesController.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 07/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CitiesController.h"
#import "BicycletteCity+Update.h"
#import "CollectionsAdditions.h"
#import "LocalUpdateQueue.h"
#import "CityRegionUpdateGroup.h"
#import "GeofencesMonitor.h"
#import "UIApplication+LocalAlerts.h"

@interface CitiesController () <CLLocationManagerDelegate, LocalUpdateQueueDelegate, GeofencesMonitorDelegate>
@property GeofencesMonitor * fenceMonitor;
@property LocalUpdateQueue * updateQueue;

@property CityRegionUpdateGroup * userLocationUpdateGroup;
@property CityRegionUpdateGroup * screenCenterUpdateGroup;

@property MKCoordinateRegion viewRegion;

@property UILocalNotification * updateInProgressNotification;
@property Geofence * updateInProgressFence;
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
        self.cities = [BicycletteCity allCities];

        self.fenceMonitor = [GeofencesMonitor new];
        self.fenceMonitor.delegate = self;
        self.updateQueue = [LocalUpdateQueue new];
        self.updateQueue.delayBetweenPointUpdates = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DataUpdaterDelayBetweenQueues"];
        self.updateQueue.moniteredGroupsMaximumDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"MaxRefreshDistance"];
        self.updateQueue.delegate = self;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityUpdated:)
                                                     name:BicycletteCityNotifications.updateSucceeded object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStateChanged:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStateChanged:) name:UIApplicationDidEnterBackgroundNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:)
                                                     name:NSUserDefaultsDidChangeNotification object:nil];

        self.userLocationUpdateGroup = [CityRegionUpdateGroup new];
        self.screenCenterUpdateGroup = [CityRegionUpdateGroup new];

    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) defaultsChanged:(NSNotification*)note
{
    [self addAndRemoveMapAnnotations];
}

/****************************************************************************/
#pragma mark -

- (BicycletteCity*) cityNamed:(NSString*)cityName
{
    return [self.cities firstObjectWithValue:cityName forKeyPath:@"cityName"];
}

- (void) setCurrentCity:(BicycletteCity *)currentCity_
{
    if(_currentCity != currentCity_)
    {
        for (Geofence * fence in [self.fenceMonitor geofencesInCity:_currentCity]) {
            [self.updateQueue removeMonitoredGroup:fence];
        }
        
        _currentCity = currentCity_;

        for (Geofence * fence in [self.fenceMonitor geofencesInCity:_currentCity]) {
            if([_currentCity canUpdateIndividualStations])
                [self.updateQueue addMonitoredGroup:fence];
        }

        [self.updateQueue removeMonitoredGroup:self.screenCenterUpdateGroup];
        [self.updateQueue removeMonitoredGroup:self.userLocationUpdateGroup];

        self.screenCenterUpdateGroup.city = _currentCity;
        self.userLocationUpdateGroup.city = _currentCity;

        [self.updateQueue addMonitoredGroup:self.screenCenterUpdateGroup];
        [self.updateQueue addMonitoredGroup:self.userLocationUpdateGroup];

        // Google Analytics
        [[GAI sharedInstance].defaultTracker setCustom:1 dimension:_currentCity.cityName];
        [[GAI sharedInstance].defaultTracker sendView:[NSString stringWithFormat:@"city_%@",_currentCity.cityName]];
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
        return [self regionSpanMeters] < [self.currentCity radius] * [[self.currentCity prefForKey:@"CitiesController.StationsZoomThreshold"] doubleValue];
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
    CLLocationDistance minRadius = [[NSUserDefaults standardUserDefaults] doubleForKey:@"Cities.MinimumRadius"];
    CLLocationDistance effectiveRadius = MAX([nearestCity radius], minRadius);
    if(distanceToCity > effectiveRadius * [[nearestCity prefForKey:@"CitiesController.CurrentCityDistanceThreshold"] doubleValue])
        nearestCity = nil;

    // Are we zooming enough ?
    if(viewSpanMeters > effectiveRadius * [[nearestCity prefForKey:@"CitiesController.CurrentCityZoomThreshold"] doubleValue])
        nearestCity = nil;
    
    if(self.currentCity!=nearestCity)
        self.currentCity = nearestCity;

    // Update annotations
    [self addAndRemoveMapAnnotations];

    // Keep the screen center Radar centered
    // And make it as big as the screen, but only if the stations are actually visible
    [self.screenCenterUpdateGroup setRegion:self.viewRegion];
    
    // In the same vein, only set the updater reference location if we're down enough
    CLLocationDistance distance = [[self.currentCity prefForKey:@"RegionMonitoring.FenceDistance"] doubleValue];
    [self.userLocationUpdateGroup setRegion:MKCoordinateRegionMakeWithDistance(self.viewRegion.center, distance, distance)];
    
    if(self.currentCity)
        [self.updateQueue setReferenceLocation:center andStartIfNecessary:[self.currentCity canUpdateIndividualStations]];
    else
        self.updateQueue.referenceLocation = nil;

    if([self showCurrentCityStations] || (self.currentCity && ![self.currentCity canUpdateIndividualStations]))
    {
        [self.updateQueue addMonitoredGroup:self.screenCenterUpdateGroup];
        [self.updateQueue addMonitoredGroup:self.userLocationUpdateGroup];
    }
    else
    {
        [self.updateQueue removeMonitoredGroup:self.screenCenterUpdateGroup];
        [self.updateQueue removeMonitoredGroup:self.userLocationUpdateGroup];
    }
}

- (void) addAndRemoveMapAnnotations
{
    NSMutableArray * newAnnotations = [NSMutableArray new];
    NSMutableArray * newOverlays = [NSMutableArray new];
    
    if (self.currentCity==nil)
    {
        // World Cities
        BOOL groupCities = [self regionSpanMeters] > [[NSUserDefaults standardUserDefaults] doubleForKey:@"CitiesController.CityGroupZoomMeters"];
        NSArray * cities = self.cities;
        if(groupCities)
            cities = [cities filteredArrayWithValue:@YES forKeyPath:@"isMainCityGroup"];
        [newAnnotations addObjectsFromArray:cities];
    }
    else
    {
        // Fences
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"RegionMonitoring.Enabled"] && [CLLocationManager regionMonitoringAvailable])
        {
            NSArray * fences = [self.fenceMonitor geofencesInCity:_currentCity];
            [newOverlays addObjectsFromArray:fences];
        }

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
            
            // Starred (always show)
            NSArray * starred = [Station fetchStarredStations:self.currentCity.mainContext];
            [newAnnotations addObjectsFromArray:starred];
        }
    }

    [self.delegate controller:self setAnnotations:newAnnotations overlays:newOverlays];
}


- (void) selectCity:(BicycletteCity*)city_
{
    CLLocationDistance threshold = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CitiesController.CityGroupZoomMeters"];
    BOOL groupCities = [self regionSpanMeters] > threshold;
    if([[city_ cityGroup] length]!=0 && groupCities) {
        // zoom around the group
        [self.delegate controller:self setRegion:MKCoordinateRegionMakeWithDistance(city_.coordinate, (threshold/2)*.8, (threshold/2)*.8)];
        [self.delegate controller:self selectAnnotation:nil];
    } else {
        // Zoom directly to city
        MKCoordinateRegion region = [city_ mkRegionContainingData];
        if(region.span.latitudeDelta == 0. || region.span.longitudeDelta == 0.) {
            CLLocationDistance minDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CitiesController.MapRegionZoomDistance"];
            region = MKCoordinateRegionMakeWithDistance(region.center, minDistance, minDistance);
        }
        [self.delegate controller:self setRegion:region];
    }
}

- (void) switchStarredStation:(Station*)station
{
    [station.city performUpdates:^(NSManagedObjectContext *updateContext) {
        Station * lstation = (Station*)[updateContext objectWithID:station.objectID];
        lstation.starredValue = !lstation.starredValue;
    } saveCompletion:^(NSNotification *contextDidSaveNotification) {
        NSArray * starredStation = [Station fetchStarredStations:station.city.mainContext];
        [self.fenceMonitor setStarredStations:starredStation inCity:station.city];
        [self addAndRemoveMapAnnotations];
    }];
}

- (BOOL) cityHasFences:(BicycletteCity*)city_
{
    return [[self.fenceMonitor geofencesInCity:city_] count]!=0;
}

/****************************************************************************/
#pragma mark -

- (void) appStateChanged:(NSNotification*)note
{
    BOOL background = [note.name isEqualToString:UIApplicationDidEnterBackgroundNotification];
    self.updateQueue.monitoringPaused = (background || self.mapViewIsMoving);
    if(!background && !self.mapViewIsMoving) {
        [self.updateQueue buildUpdateQueue];
    }
}

- (void) setMapViewIsMoving:(BOOL)moving
{
    _mapViewIsMoving = moving;
    BOOL background = [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground;
    self.updateQueue.monitoringPaused = (background || self.mapViewIsMoving);
}

/****************************************************************************/
#pragma mark -

- (void)monitor:(GeofencesMonitor *)monitor fenceMonitoringFailed:(Geofence *)fence withError:(NSError *)error
{
    NSArray * objectIDs = [fence.stations valueForKeyPath:@"objectID"];
    [fence.city performUpdates:^(NSManagedObjectContext *updateContext) {
        for (NSManagedObjectID * stationID in objectIDs) {
            Station * station = (Station *)[updateContext objectWithID:stationID];
            station.starredValue = NO;
        }
    } saveCompletion:^(NSNotification *contextDidSaveNotification) {
        NSString * message = [NSString stringWithFormat:@"%@\n%@",
                              NSLocalizedString(@"FENCE_MONITORING_ERROR_MESSAGE",nil),
                              [error localizedDescription]];
        [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"FENCE_MONITORING_ERROR_TITLE",nil)
                                   message:message
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"FENCE_MONITORING_ERROR_OK",nil)
                         otherButtonTitles:nil]
         show];
        NSArray * starredStation = [Station fetchStarredStations:fence.city.mainContext];
        [self.fenceMonitor setStarredStations:starredStation inCity:fence.city];
        [self addAndRemoveMapAnnotations];
    }];
    
}

- (void) monitor:(GeofencesMonitor*)monitor fenceWasEntered:(Geofence*)fence
{
    if(self.updateInProgressNotification)
        [[UIApplication sharedApplication] cancelLocalNotification:self.updateInProgressNotification];
    
    self.updateInProgressFence = fence;
    self.updateInProgressNotification = [[UIApplication sharedApplication] presentLocalNotificationMessage:NSLocalizedString(@"UPDATING : PARSING", nil)
                                                                                               alertAction:nil
                                                                                                 soundName:nil
                                                                                                  userInfo:nil
                                                                                                  fireDate:nil];

    [self.updateQueue addOneshotGroup:fence];
}

- (void) monitor:(GeofencesMonitor*)monitor fenceWasExited:(Geofence*)fence
{
    [self.updateQueue removeOneshotGroup:fence];
}

/****************************************************************************/
#pragma mark -

- (void) updateQueue:(LocalUpdateQueue *)queue didUpdateOneshotPoint:(id<LocalUpdatePoint>)point ofGroup:(Geofence*)fence
{
    NSAssert([fence isKindOfClass:[Geofence class]],nil);
    if([point isKindOfClass:[Station class]]) {
        [[UIApplication sharedApplication] presentLocalNotificationForStationSummary:(Station*)point];
    } else {
        NSAssert(point==self.updateInProgressFence.city, nil);
        for (Station * station in self.updateInProgressFence.stations) {
            [[UIApplication sharedApplication] presentLocalNotificationForStationSummary:station];
        }
        
    }
}

- (void) updateQueueDidComplete:(LocalUpdateQueue *)queue
{
    if(self.updateInProgressNotification) {
        [[UIApplication sharedApplication] cancelLocalNotification:self.updateInProgressNotification];
        self.updateInProgressFence = nil;
    }
    self.updateInProgressNotification = nil;
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

- (void) handleLocalNotificaion:(UILocalNotification*)notification
{
    [self selectStationNumber:notification.userInfo[@"stationNumber"] inCityNamed:notification.userInfo[@"city"] changeRegion:YES];
}

- (void) selectStationNumber:(NSString*)stationNumber inCityNamed:(NSString*)cityName changeRegion:(BOOL)changeRegion
{
    BicycletteCity * city = [self cityNamed:cityName];
    
    Station * station = nil;
    if(stationNumber)
    {
        station = [city stationWithNumber:stationNumber];
    }
    
    if(city && stationNumber)
    {
        self.currentCity = city;
        if(changeRegion)
        {
            CLLocationDistance meters = [[city prefForKey:@"CitiesController.MapRegionZoomDistance"] doubleValue];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(station.coordinate, meters, meters);
            [self.delegate controller:self setRegion:region];
        }
        [self.delegate controller:self selectAnnotation:station];
    }
}

@end
