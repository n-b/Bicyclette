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
#import "NSArrayAdditions.h"

#import "LocalUpdateQueue.h"
#import "GeoFencesMonitor.h"

#import "ParisVelibCity.h"
#import "MarseilleLeveloCity.h"
#import "ToulouseVeloCity.h"
#import "AmiensVelamCity.h"


@interface CitiesController ()
@property GeoFencesMonitor * fenceMonitor;
@property LocalUpdateQueue * updateQueue;
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
                       [MarseilleLeveloCity new],
                       [ToulouseVeloCity new],
                       [AmiensVelamCity new] ]);

        self.fenceMonitor = [GeoFencesMonitor new];
        self.updateQueue = [LocalUpdateQueue new];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityUpdated:)
                                                     name:BicycletteCityNotifications.updateSucceeded object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsChanged:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification object:nil];

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
	[self.delegate setRegion:region];
    
    [self addAndRemoveMapAnnotations];
}

- (void) setLevel:(MapLevel)level_
{
    if(_level==level_)
        return;
    
    _level = level_;
    if(self.level == MapLevelNone)
        self.currentCity = nil;
    else
    {
        CLLocationCoordinate2D centerCoord = [self.delegate region].center;
        CLLocation * center = [[CLLocation alloc] initWithLatitude:centerCoord.latitude longitude:centerCoord.longitude];
        NSMutableArray * sortedCities = [self.cities mutableCopy];
        [sortedCities sortByDistanceFromLocation:center];
        self.currentCity = sortedCities[0];
    }
}

- (void) setCurrentCity:(BicycletteCity *)currentCity_
{
    _currentCity = currentCity_;
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.citySelected object:self.currentCity];
}

- (void) regionDidChange:(MKCoordinateRegion)viewRegion
{
    CLLocation * northLocation = [[CLLocation alloc] initWithLatitude:viewRegion.center.latitude+viewRegion.span.latitudeDelta longitude:viewRegion.center.longitude/2];
    CLLocation * southLocation = [[CLLocation alloc] initWithLatitude:viewRegion.center.latitude-viewRegion.span.latitudeDelta longitude:viewRegion.center.longitude/2];
    CLLocation * westLocation = [[CLLocation alloc] initWithLatitude:viewRegion.center.latitude longitude:viewRegion.center.latitude-viewRegion.span.longitudeDelta/2];
    CLLocation * eastLocation = [[CLLocation alloc] initWithLatitude:viewRegion.center.latitude longitude:viewRegion.center.latitude+viewRegion.span.longitudeDelta/2];
    CLLocationDistance latDistance = [northLocation distanceFromLocation:southLocation];
    CLLocationDistance longDistance = [eastLocation distanceFromLocation:westLocation];
    CLLocationDistance avgDistance = (latDistance+longDistance)/2;

    if(avgDistance > [[NSUserDefaults standardUserDefaults] doubleForKey:@"MapLevelRegions"])
		self.level = MapLevelNone;
	else if(avgDistance > [[NSUserDefaults standardUserDefaults] doubleForKey:@"MapLevelRegionsAndRadars"])
		self.level = MapLevelRegions;
    else if(avgDistance > [[NSUserDefaults standardUserDefaults] doubleForKey:@"MapLevelStationsAndRadars"])
		self.level = MapLevelRegionsAndRadars;
	else
		self.level = MapLevelStationsAndRadars;
    
    [self addAndRemoveMapAnnotations];

    // Keep the screen center Radar centered
    self.currentCity.screenCenterRadar.coordinate = [self.delegate region].center;

    // And make it as big as the screen, but only if the stations are actually visible
    if(self.level==MapLevelStationsAndRadars)
        self.currentCity.screenCenterRadar.customRadarSpan = [self.delegate region].span;
    else
        self.currentCity.screenCenterRadar.customRadarSpan = MKCoordinateSpanMake(0, 0);
    
    // In the same vein, only set the updater reference location if we're down enough
    if(self.level==MapLevelRegionsAndRadars || self.level==MapLevelStationsAndRadars)
    {
        CLLocationCoordinate2D center = [self.delegate region].center;
        self.updateQueue.referenceLocation = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
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
        NSFetchRequest * regionsRequest = [NSFetchRequest new];
        regionsRequest.entity = [Region entityInManagedObjectContext:self.currentCity.moc];
        [newAnnotations addObjectsFromArray:[self.currentCity.moc executeFetchRequest:regionsRequest error:NULL]];
    }
    
    if (self.level == MapLevelRegionsAndRadars || self.level == MapLevelStationsAndRadars)
    {
        // Radars
        NSFetchRequest * radarsRequest = [NSFetchRequest new];
        [radarsRequest setEntity:[Radar entityInManagedObjectContext:self.currentCity.moc]];
        NSMutableArray * allRadars = [[self.currentCity.moc executeFetchRequest:radarsRequest error:NULL] mutableCopy];
        // do not add an annotation for screenCenterRadar, it's handled separately.
        [allRadars removeObject:self.currentCity.screenCenterRadar];
//        // only add the userLocationRadar if it's actually here
//        if(self.mapView.userLocation.coordinate.latitude==0.0)
//            [allRadars removeObject:self.currentCity.userLocationRadar];
        [newAnnotations addObjectsFromArray:[newAnnotations arrayByAddingObjectsFromArray:allRadars]];
    }
    
    if (self.level == MapLevelStationsAndRadars)
    {
        // Stations
        NSFetchRequest * stationsRequest = [NSFetchRequest new];
		[stationsRequest setEntity:[Station entityInManagedObjectContext:self.currentCity.moc]];
        MKCoordinateRegion mapRegion = [self.delegate region];
		stationsRequest.predicate = [NSPredicate predicateWithFormat:@"latitude>%f AND latitude<%f AND longitude>%f AND longitude<%f",
                                     mapRegion.center.latitude - mapRegion.span.latitudeDelta/2,
                                     mapRegion.center.latitude + mapRegion.span.latitudeDelta/2,
                                     mapRegion.center.longitude - mapRegion.span.longitudeDelta/2,
                                     mapRegion.center.longitude + mapRegion.span.longitudeDelta/2];
        [newAnnotations addObjectsFromArray:[self.currentCity.moc executeFetchRequest:stationsRequest error:NULL]];
    }
    
    [self.delegate setAnnotations:newAnnotations];
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
            [self.updateQueue addGroup:object];
    }

    for (id object in note.userInfo[NSDeletedObjectsKey]) {
        if([object conformsToProtocol:@protocol(GeoFence)])
            [self.fenceMonitor removeFence:object];
        if([object conformsToProtocol:@protocol(LocalUpdateGroup)])
            [self.updateQueue removeGroup:object];
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
        [self.delegate setRegion:region];
        [self.delegate selectAnnotation:station];
    }
}

@end
