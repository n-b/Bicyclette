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
#import "NSArrayAdditions.h"
#import "NSMutableArray+Stations.h"
#import "RegionAnnotationView.h"
#import "StationAnnotationView.h"
#import "DrawingCache.h"
#import "Radar.h"
#import "RadarAnnotationView.h"

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

@property (nonatomic) NSArray * refreshedStations;
@end

//static CGFloat DistanceBetweenCGPoints(CGPoint point1,CGPoint point2)
//{
//    CGFloat dx = point2.x - point1.x;
//    CGFloat dy = point2.y - point1.y;
//    return sqrt(dx*dx + dy*dy );
//};


/****************************************************************************/
#pragma mark -

@implementation MapVC 
{
    DrawingCache * _drawingCache;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil) {
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

        _drawingCache = [DrawingCache new];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

/****************************************************************************/
#pragma mark Loading

- (void) loadView
{
    self.mapView = [[MKMapView alloc]initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view = self.mapView;
    self.mapView.showsUserLocation = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.delegate = self;

    UIGestureRecognizer * longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addRadar:)];
    [self.mapView addGestureRecognizer:longPressRecognizer];
    
    self.userTrackingButton.mapView = self.mapView;

    [self reloadData];
}

- (void) reloadData
{
    MKCoordinateRegion region = [self.mapView regionThatFits:self.model.regionContainingData];
    region.span.latitudeDelta /= 2;
    region.span.longitudeDelta /= 2;
    self.referenceRegion = region;

	self.mapView.region = self.referenceRegion;

    [self addAndRemoveMapAnnotations];
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
    
    [self addAndRemoveMapAnnotations];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView_ viewForAnnotation:(id <MKAnnotation>)annotation
{
	if(annotation == self.mapView.userLocation)
		return nil;
	else if([annotation isKindOfClass:[Region class]])
	{
		RegionAnnotationView * regionAV = (RegionAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:[RegionAnnotationView reuseIdentifier]];
		if(nil==regionAV)
			regionAV = [[RegionAnnotationView alloc] initWithRegion:annotation drawingCache:_drawingCache];

        return regionAV;
	}
	else if([annotation isKindOfClass:[Station class]])
	{
		StationAnnotationView * stationAV = (StationAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:[StationAnnotationView reuseIdentifier]];
		if(nil==stationAV)
			stationAV = [[StationAnnotationView alloc] initWithStation:annotation drawingCache:_drawingCache];

        stationAV.display = self.display;
		return stationAV;
	}
    else if([annotation isKindOfClass:[Radar class]])
    {
        RadarAnnotationView * radarAV = (RadarAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:[RadarAnnotationView reuseIdentifier]];
		if(nil==radarAV)
			radarAV = [[RadarAnnotationView alloc] initWithRadar:annotation];
        else
            radarAV.annotation = annotation;
        radarAV.draggable = annotation!=[self.model userLocationRadar] && annotation!=[self.model screenCenterRadar];
        return radarAV;
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

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
fromOldState:(MKAnnotationViewDragState)oldState
{
    NSLog(@"drag %@",view);
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self.model userLocationRadar].coordinate = userLocation.coordinate;
}

- (void) addAndRemoveMapAnnotations
{
    NSArray * oldAnnotations = self.mapView.annotations;
    [oldAnnotations arrayByRemovingObjectsInArray:@[ self.mapView.userLocation ]];
    NSArray * newAnnotations;
    

    if (self.mode == MapModeRegions)
    {
        NSFetchRequest * regionsRequest = [NSFetchRequest new];
        regionsRequest.entity = [Region entityInManagedObjectContext:self.model.moc];
        newAnnotations = [self.model.moc executeFetchRequest:regionsRequest error:NULL];
    }
    else
    {
        NSFetchRequest * stationsRequest = [NSFetchRequest new];
		[stationsRequest setEntity:[Station entityInManagedObjectContext:self.model.moc]];
        MKCoordinateRegion mapRegion = self.mapView.region;
		stationsRequest.predicate = [NSPredicate predicateWithFormat:@"latitude>%f AND latitude<%f AND longitude>%f AND longitude<%f",
							 mapRegion.center.latitude - mapRegion.span.latitudeDelta/2,
                             mapRegion.center.latitude + mapRegion.span.latitudeDelta/2,
                             mapRegion.center.longitude - mapRegion.span.longitudeDelta/2,
                             mapRegion.center.longitude + mapRegion.span.longitudeDelta/2];
        newAnnotations = [self.model.moc executeFetchRequest:stationsRequest error:NULL];

        NSFetchRequest * radarsRequest = [NSFetchRequest new];
		[radarsRequest setEntity:[Radar entityInManagedObjectContext:self.model.moc]];
        newAnnotations = [newAnnotations arrayByAddingObjectsFromArray:[self.model.moc executeFetchRequest:radarsRequest error:NULL]];
    }

    NSArray * annotationsToRemove = [oldAnnotations arrayByRemovingObjectsInArray:newAnnotations];
    NSArray * annotationsToAdd = [newAnnotations arrayByRemovingObjectsInArray:oldAnnotations];
    
    [self.mapView removeAnnotations:annotationsToRemove];
    [self.mapView addAnnotations:annotationsToAdd];
    
    if(self.mode==MapModeStations)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshVisibleStations) object:nil];
        [self performSelector:@selector(refreshVisibleStations) withObject:nil afterDelay:.5];
    }
}

/****************************************************************************/
#pragma mark Refresh

- (void) refreshVisibleStations
{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
//
//    if(self.mode==MapModeStations)
//    {
//        NSMutableArray * visibleStations = [[[self.mapView annotationsInMapRect:self.mapView.visibleMapRect] allObjects] mutableCopy];
//        [visibleStations filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<MKAnnotation> annotation, NSDictionary *bindings) {
//            return [annotation isKindOfClass:[Station class]];
//        }]];
//        
//        CLLocation * referenceLocation;
//        if(self.mapView.userLocationVisible)
//            referenceLocation = self.mapView.userLocation.location;
//        else
//        {
//            CLLocationCoordinate2D coord = self.mapView.centerCoordinate;
//            referenceLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
//        }
//        
//        CLLocationDistance radarDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadarDistance"];
//        
//        [visibleStations filterStationsWithinDistance:radarDistance fromLocation:referenceLocation];
//        [visibleStations sortStationsNearestFirstFromLocation:referenceLocation];
//
//        NSArray * annotationsNotToRefreshAnymore = [self.refreshedStations arrayByRemovingObjectsInArray:visibleStations];
//        [annotationsNotToRefreshAnymore makeObjectsPerformSelector:@selector(cancel)];
//        [visibleStations makeObjectsPerformSelector:@selector(refresh)];
//
//        self.radar.coordinate = referenceLocation.coordinate;
//        [self.mapView addAnnotation:self.radar];
//        self.refreshedStations = visibleStations;
//    }
//    else
//    {
//        self.refreshedStations = nil;
//    }
}

- (void) setRefreshedStations:(NSArray *)refreshedStations_
{
    for (Station* station in _refreshedStations)
        [station removeObserver:self forKeyPath:@"refreshing" context:(__bridge void *)([MapVC class])];
    _refreshedStations = refreshedStations_;
    for (Station* station in _refreshedStations)
        [station addObserver:self forKeyPath:@"refreshing" options:0 context:(__bridge void *)([MapVC class])];
}

- (void) stationRefreshChanged
{
//    NSMutableArray * stationsStillRefreshing = [[self.refreshedStations filteredArrayWithValue:@YES forKey:@"refreshing"] mutableCopy];
//    if([stationsStillRefreshing count])
//    {
//        [stationsStillRefreshing sortStationsNearestFirstFromLocation:[[CLLocation alloc] initWithLatitude:self.radar.coordinate.latitude longitude:self.radar.coordinate.longitude]];
//        
//        Station * nearestRefreshing = [stationsStillRefreshing objectAtIndex:0];
//        Station * fartherRefreshing = [stationsStillRefreshing lastObject];
//        
//        CGPoint nearPoint = [self.mapView convertCoordinate:nearestRefreshing.coordinate toPointToView:self.mapView];
//        CGPoint farPoint = [self.mapView convertCoordinate:fartherRefreshing.coordinate toPointToView:self.mapView];
//        
//        CGPoint referencePoint = [self.mapView convertCoordinate:self.radar.coordinate toPointToView:self.mapView];
//        
//        self.radar.nearRadius = DistanceBetweenCGPoints(nearPoint, referencePoint);
//        self.radar.farRadius = DistanceBetweenCGPoints(farPoint, referencePoint);
//    }
//    else
//    {
//        self.radar.nearRadius = 0;
//        self.radar.farRadius = 0;
//    }
}

/****************************************************************************/
#pragma mark Actions

- (void) addRadar:(UILongPressGestureRecognizer*)longPressRecognizer
{
    if(longPressRecognizer.state==UIGestureRecognizerStateBegan)
    {
        Radar * r = [Radar insertInManagedObjectContext:self.model.moc];
        r.coordinate = [self.mapView convertPoint:[longPressRecognizer locationInView:self.mapView]
                             toCoordinateFromView:self.mapView];
        r.nearRadius = 40;
        r.farRadius = 40;

        [self.mapView addAnnotation:r];
    }
}

- (void) showDetails:(Station*)station
{
    [station refresh];
}

- (void) zoomIn:(Region*)region
{
    MKCoordinateRegion cregion = [self.mapView regionThatFits:region.coordinateRegion];
    cregion = MKCoordinateRegionMakeWithDistance(cregion.center, 1000, 1000);
	[self.mapView setRegion:cregion animated:YES];
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
            if([stationAV isKindOfClass:[StationAnnotationView class]])
                stationAV.display = self.display;
        }
    }
}

/****************************************************************************/
#pragma mark -

- (void) modelUpdated:(NSNotification*) note
{
    if([note.userInfo[VelibModelNotifications.keys.dataChanged] boolValue])
        [self reloadData];
}

/****************************************************************************/
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([MapVC class]))
    {
        if([keyPath isEqualToString:@"refreshing"]) [self stationRefreshChanged];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
