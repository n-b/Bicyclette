//
//  MapVC.m
//  Bicyclette
//
//  Created by Nicolas on 04/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "MapVC.h"
#import "BicycletteApplicationDelegate.h"
#import "VelibModel.h"
#import "Station.h"
#import "Region.h"
#import "StationDetailVC.h"
#import "NSArrayAdditions.h"
#import "VelibModel+Favorites.h"
#import "RegionAnnotationView.h"
#import "StationAnnotationView.h"
#import "LayerCache.h"


typedef enum {
	MapModeNone = 0,
	MapModeRegions,
	MapModeStations
}  MapMode;

@interface MapVC() <MKMapViewDelegate>

// Outlets
@property MKMapView * mapView;
@property MKUserTrackingBarButtonItem * userTrackingButton;
@property UISegmentedControl * displayControl;
@property UIButton * infoButton;

@property MKCoordinateRegion referenceRegion;
@property (nonatomic) MapMode mode;
@property (nonatomic) MapDisplay display;

@end

/****************************************************************************/
#pragma mark -

@implementation MapVC 
{
    LayerCache * _layerCache;
    
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteDidChange:) 
													 name:VelibModelNotifications.favoriteChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelUpdated:)
                                                     name:VelibModelNotifications.updateSucceeded object:nil];


        self.userTrackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:nil];
        
        _displayControl = [[UISegmentedControl alloc] initWithItems:@[ NSLocalizedString(@"BIKES", nil), NSLocalizedString(@"PARKING", nil) ]];
        _displayControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [_displayControl addTarget:self action:@selector(switchDisplay:) forControlEvents:UIControlEventValueChanged];
        _displayControl.selectedSegmentIndex = self.display;

        _infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [_infoButton addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
        _infoButton.showsTouchWhenHighlighted = NO;
        
        self.toolbarItems = @[self.userTrackingButton,
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        [[UIBarButtonItem alloc] initWithCustomView:_displayControl],
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        [[UIBarButtonItem alloc] initWithCustomView:_infoButton]];

        _layerCache = [LayerCache new];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

/****************************************************************************/
#pragma mark -

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void) loadView
{
    self.mapView = [[MKMapView alloc]initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view = self.mapView;
    self.mapView.showsUserLocation = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.delegate = self;
    
    self.userTrackingButton.mapView = self.mapView;

    [self reloadData];
}


- (void) viewDidUnload
{
    self.mapView = nil;
    [super viewDidUnload];
}

- (void) reloadData
{
    self.referenceRegion = [self.mapView regionThatFits:BicycletteAppDelegate.model.regionContainingData];
	self.mapView.region = self.referenceRegion;

    [self updateAnnotations];
}

/****************************************************************************/
#pragma mark MapView Delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	CLLocationDegrees modelSpan = self.referenceRegion.span.latitudeDelta;
	if(self.mapView.region.span.latitudeDelta>modelSpan/10.0f)
		self.mode = MapModeRegions;
	else
		self.mode = MapModeStations;

    self.displayControl.enabled = (self.mode==MapModeStations);
        
    [self updateAnnotations];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView_ viewForAnnotation:(id <MKAnnotation>)annotation
{
	if(annotation == self.mapView.userLocation)
		return nil;
	else if([annotation isKindOfClass:[Region class]])
	{
		RegionAnnotationView * regionAV = (RegionAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:[RegionAnnotationView reuseIdentifier]];
		if(nil==regionAV)
			regionAV = [[RegionAnnotationView alloc] initWithRegion:annotation layerCache:_layerCache];

        return regionAV;
	}
	else if([annotation isKindOfClass:[Station class]])
	{
		StationAnnotationView * stationAV = (StationAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:[StationAnnotationView reuseIdentifier]];
		if(nil==stationAV)
			stationAV = [[StationAnnotationView alloc] initWithStation:annotation layerCache:_layerCache];

        stationAV.display = self.display;
		return stationAV;
	}
	return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	if([view.annotation isKindOfClass:[Region class]])
		[self zoomIn:(Region*)view.annotation];
    else if([view.annotation isKindOfClass:[Station class]])
        [self showDetails:(Station*)view.annotation];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
}

- (void) updateAnnotations
{
    NSArray * oldAnnotations = self.mapView.annotations;
    NSFetchRequest * request = [NSFetchRequest new];

    if (self.mode == MapModeRegions)
    {
        request.entity = [Region entityInManagedObjectContext:BicycletteAppDelegate.model.moc];
    }
    else
    {
		[request setEntity:[Station entityInManagedObjectContext:BicycletteAppDelegate.model.moc]];
        MKCoordinateRegion mapRegion = self.mapView.region;
		request.predicate = [NSPredicate predicateWithFormat:@"latitude>%f AND latitude<%f AND longitude>%f AND longitude<%f",
							 mapRegion.center.latitude - mapRegion.span.latitudeDelta, 
                             mapRegion.center.latitude + mapRegion.span.latitudeDelta,
                             mapRegion.center.longitude - mapRegion.span.longitudeDelta, 
                             mapRegion.center.longitude + mapRegion.span.longitudeDelta];
    }

    NSArray * newAnnotations = [BicycletteAppDelegate.model.moc executeFetchRequest:request error:NULL];

    NSMutableArray * annotationsToRemove = [oldAnnotations mutableCopy];
    [annotationsToRemove removeObjectsInArray:newAnnotations];
    [annotationsToRemove removeObject:self.mapView.userLocation];
    NSArray * annotationsToAdd = [newAnnotations arrayByRemovingObjectsInArray:oldAnnotations];
    
    [self.mapView removeAnnotations:annotationsToRemove];
    [self.mapView addAnnotations:annotationsToAdd];
    
    if(self.mode==MapModeStations)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVisibleStations) object:nil];
        [self performSelector:@selector(updateVisibleStations) withObject:nil afterDelay:.5];
    }
}

- (void) updateVisibleStations
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    MKMapRect rect = self.mapView.visibleMapRect;
    rect.size.width /= 2;
    rect.size.height /= 2;
    rect.origin.x += rect.size.width / 2;
    rect.origin.y += rect.size.height / 2;

    NSArray * visibleAnnotations = [[self.mapView annotationsInMapRect:rect] allObjects];
    CLLocation * referenceLocation;
    if(self.mapView.userLocationVisible)
        referenceLocation = self.mapView.userLocation.location;
    else
    {
        CLLocationCoordinate2D coord = self.mapView.centerCoordinate;
        referenceLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    }
    visibleAnnotations = [visibleAnnotations sortedArrayUsingComparator:^NSComparisonResult(Station * station1, Station * station2) {
        CLLocationDistance d1 = [referenceLocation distanceFromLocation:station1.location];
        CLLocationDistance d2 = [referenceLocation distanceFromLocation:station2.location];
        return d1<d2 ? NSOrderedAscending : d1>d2 ? NSOrderedDescending : NSOrderedSame;
    }];
    [visibleAnnotations makeObjectsPerformSelector:@selector(refresh)];
}

/****************************************************************************/
#pragma mark Actions

- (void) showDetails:(Station*)station
{
}

- (void) zoomIn:(Region*)region
{
	[self.mapView setRegion:[self.mapView regionThatFits:region.coordinateRegion] animated:YES];
}

- (void) showInfo:(UIButton*)sender
{
    
}

- (void) switchDisplay:(UISegmentedControl*)sender
{
    self.display = sender.selectedSegmentIndex;

    if(self.mode==MapModeStations)
    {
        for (id<MKAnnotation> annotation in self.mapView.annotations) {
            StationAnnotationView * stationAV = (StationAnnotationView*)[self.mapView viewForAnnotation:annotation];
            stationAV.display = self.display;
        }
    }
}

/****************************************************************************/
#pragma mark -

- (void) favoriteDidChange:(NSNotification*)note
{
	Station * station = note.object;
	MKPinAnnotationView * pinView = (MKPinAnnotationView*)[self.mapView viewForAnnotation:station];
	pinView.pinColor = [station isFavorite]?MKPinAnnotationColorRed:MKPinAnnotationColorGreen;
}

- (void) modelUpdated:(NSNotification*) note
{
    if([note.userInfo[VelibModelNotifications.keys.dataChanged] boolValue])
        [self reloadData];
}

@end
