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
#import "TransparentToolbar.h"
#import "NSArrayAdditions.h"
#import "RegionAnnotationView.h"
#import "StationAnnotationView.h"
#import "DrawingCache.h"
#import "Radar.h"
#import "RadarAnnotationView.h"
#import "RadarUpdateQueue.h"
#import "MKMapView+AttributionLogo.h"

typedef enum {
	MapLevelNone = 0,
	MapLevelRegions,
	MapLevelRegionsAndRadars,
	MapLevelStationsAndRadars
}  MapLevel;

@interface MapVC() <MKMapViewDelegate>
// UI
@property MKMapView * mapView;
@property UIToolbar * mapVCToolbar; // Do not use the system toolbal to prevent its height from changing
@property MKUserTrackingBarButtonItem * userTrackingButton;
@property UISegmentedControl * modeControl;
// Data
@property MKCoordinateRegion referenceRegion;
@property (nonatomic) MapLevel level;
@property (nonatomic) StationAnnotationMode stationMode;

// Radar creation
@property (nonatomic) Radar * droppedRadar;
@end


/****************************************************************************/
#pragma mark -

@implementation MapVC 
{
    DrawingCache * _drawingCache;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelUpdated:)
                                                 name:VelibModelNotifications.updateSucceeded object:nil];
        
    _drawingCache = [DrawingCache new];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

/****************************************************************************/
#pragma mark Loading

- (BOOL) canBecomeFirstResponder
{
    return YES;
}

- (void) loadView
{
    [super loadView]; // get a base view

    // Compute frames
    // on iPhone, the toolbar is transparent and the mapview is visible beneath it.
    // on iPad, it's opaque.
#define kToolbarHeight 44 // Strange. I was expecting to find a declared constant for it.
    CGRect mapViewFrame, toolBarFrame;
    CGRectDivide(self.view.bounds, &toolBarFrame, &mapViewFrame, kToolbarHeight, CGRectMaxYEdge);
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        mapViewFrame = self.view.bounds;

    // Create mapview
    self.mapView = [[MKMapView alloc]initWithFrame:mapViewFrame];
    [self.view addSubview:self.mapView];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.delegate = self;
    
    // Add gesture recognizer for menu
    UIGestureRecognizer * longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addRadar:)];
    [self.mapView addGestureRecognizer:longPressRecognizer];

    // prepare toolbar items
    self.userTrackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    
    self.modeControl = [[UISegmentedControl alloc] initWithItems:@[ NSLocalizedString(@"BIKE", nil), NSLocalizedString(@"PARKING", nil) ]];
    self.modeControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.modeControl addTarget:self action:@selector(switchMode:) forControlEvents:UIControlEventValueChanged];
    self.modeControl.selectedSegmentIndex = self.stationMode;
    UIBarButtonItem * modeItem = [[UIBarButtonItem alloc] initWithCustomView:self.modeControl];
    modeItem.width = 160;
    
    // create toolbar
    self.mapVCToolbar = [[TransparentToolbar alloc] initWithFrame:toolBarFrame];
    self.mapVCToolbar.barStyle = UIBarStyleBlack;
    [self.view addSubview:self.mapVCToolbar];
    self.mapVCToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.mapVCToolbar.items = @[self.userTrackingButton,
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
    modeItem,
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        self.mapVCToolbar.translucent = YES; // means transparent actually

    // observe changes to the prefs
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"RadarDistance" options:0 context:(__bridge void *)([MapVC class])];

    // Forget old userLocation, until we have a better one
    [self.model userLocationRadar].coordinate = CLLocationCoordinate2DMake(0, 0);

    // reload data
    [self reloadData];
    
    // Debug for screenshot (Default.png)
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"DebugScreenshotForDefaultMode"])
    {
        self.modeControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    }
}

- (void) startUsingUserLocation
{
    self.mapView.showsUserLocation = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView relocateAttributionLogoIfNecessary];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.mapView relocateAttributionLogoIfNecessary];
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

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

/****************************************************************************/
#pragma mark MapView Delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MKCoordinateRegion viewRegion = self.mapView.region;
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
    [self updateRadarSizes];

    self.model.screenCenterRadar.coordinate = [self.mapView convertPoint:self.mapView.center toCoordinateFromView:self.mapView.superview];
    if(self.level==MapLevelRegionsAndRadars || self.level==MapLevelStationsAndRadars)
        self.model.updaterQueue.referenceLocation = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    else
        self.model.updaterQueue.referenceLocation = nil;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView_ viewForAnnotation:(id <MKAnnotation>)annotation
{
	if(annotation == self.mapView.userLocation)
		return nil;
	else if([annotation isKindOfClass:[Region class]])
	{
		RegionAnnotationView * regionAV = (RegionAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:[RegionAnnotationView reuseIdentifier]];
		if(nil==regionAV)
			regionAV = [[RegionAnnotationView alloc] initWithAnnotation:annotation drawingCache:_drawingCache];

        return regionAV;
	}
	else if([annotation isKindOfClass:[Station class]])
	{
		StationAnnotationView * stationAV = (StationAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:[StationAnnotationView reuseIdentifier]];
		if(nil==stationAV)
			stationAV = [[StationAnnotationView alloc] initWithAnnotation:annotation drawingCache:_drawingCache];

        stationAV.mode = self.stationMode;
		return stationAV;
	}
    else if([annotation isKindOfClass:[Radar class]])
    {
        RadarAnnotationView * radarAV = (RadarAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:[RadarAnnotationView reuseIdentifier]];
		if(nil==radarAV)
			radarAV = [[RadarAnnotationView alloc] initWithAnnotation:annotation drawingCache:_drawingCache];
        
        CGSize radarSize = [self.mapView convertRegion:((Radar*)annotation).radarRegion toRectToView:self.mapView].size;
        radarAV.bounds = (CGRect){CGPointZero, radarSize};

        return radarAV;
    }
	return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	if([view.annotation isKindOfClass:[Region class]])
		[self zoomInRegion:(Region*)view.annotation];
    else if([view.annotation isKindOfClass:[Station class]])
        [self refreshStation:(Station*)view.annotation]; 
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
fromOldState:(MKAnnotationViewDragState)oldState
{
    if([view.annotation isKindOfClass:[Radar class]])
    {
        [self.mapView selectAnnotation:view.annotation animated:YES];
        if(newState==MKAnnotationViewDragStateCanceling)
            [self showRadarMenu:(Radar*)view.annotation];
    }

}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D oldCoord = [self.model userLocationRadar].coordinate;
    CLLocationCoordinate2D newCoord = userLocation.coordinate;
    if(oldCoord.latitude != newCoord.latitude || oldCoord.longitude != newCoord.longitude)
        [self.model userLocationRadar].coordinate = newCoord;

    if(oldCoord.latitude == 0 && oldCoord.longitude == 0
       && newCoord.latitude == 0 && newCoord.longitude == 0
       && newCoord.latitude > self.referenceRegion.center.latitude - self.referenceRegion.span.latitudeDelta
       && newCoord.latitude < self.referenceRegion.center.latitude + self.referenceRegion.span.latitudeDelta
       && newCoord.longitude > self.referenceRegion.center.longitude - self.referenceRegion.span.longitudeDelta
       && newCoord.longitude < self.referenceRegion.center.longitude + self.referenceRegion.span.longitudeDelta)
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void) addAndRemoveMapAnnotations
{
    NSArray * oldAnnotations = self.mapView.annotations;
    oldAnnotations = [oldAnnotations arrayByRemovingObjectsInArray:@[ self.mapView.userLocation ]];
    NSMutableArray * newAnnotations = [NSMutableArray new];

    if (self.level == MapLevelNone)
    {
        // Model
        [newAnnotations addObject:self.model];
    }

    if (self.level == MapLevelRegions || self.level == MapLevelRegionsAndRadars)
    {
        // Regions
        NSFetchRequest * regionsRequest = [NSFetchRequest new];
        regionsRequest.entity = [Region entityInManagedObjectContext:self.model.moc];
        [newAnnotations addObjectsFromArray:[self.model.moc executeFetchRequest:regionsRequest error:NULL]];
    }
    
    if (self.level == MapLevelRegionsAndRadars || self.level == MapLevelStationsAndRadars)
    {
        // Radars
        NSFetchRequest * radarsRequest = [NSFetchRequest new];
        [radarsRequest setEntity:[Radar entityInManagedObjectContext:self.model.moc]];
        NSMutableArray * allRadars = [[self.model.moc executeFetchRequest:radarsRequest error:NULL] mutableCopy];
        // do not add an annotation for screenCenterRadar, it's handled separately.
        [allRadars removeObject:self.model.screenCenterRadar];
        // only add the userLocationRadar if it's actually here
        if(self.mapView.userLocation.coordinate.latitude==0.0)
            [allRadars removeObject:self.model.userLocationRadar];
        [newAnnotations addObjectsFromArray:[newAnnotations arrayByAddingObjectsFromArray:allRadars]];
    }

    if (self.level == MapLevelStationsAndRadars)
    {
        // Stations
        NSFetchRequest * stationsRequest = [NSFetchRequest new];
		[stationsRequest setEntity:[Station entityInManagedObjectContext:self.model.moc]];
        MKCoordinateRegion mapRegion = self.mapView.region;
		stationsRequest.predicate = [NSPredicate predicateWithFormat:@"latitude>%f AND latitude<%f AND longitude>%f AND longitude<%f",
							 mapRegion.center.latitude - mapRegion.span.latitudeDelta/2,
                             mapRegion.center.latitude + mapRegion.span.latitudeDelta/2,
                             mapRegion.center.longitude - mapRegion.span.longitudeDelta/2,
                             mapRegion.center.longitude + mapRegion.span.longitudeDelta/2];
        [newAnnotations addObjectsFromArray:[self.model.moc executeFetchRequest:stationsRequest error:NULL]];
    }

    NSArray * annotationsToRemove = [oldAnnotations arrayByRemovingObjectsInArray:newAnnotations];
    NSArray * annotationsToAdd = [newAnnotations arrayByRemovingObjectsInArray:oldAnnotations];
    
    [self.mapView removeAnnotations:annotationsToRemove];
    [self.mapView addAnnotations:annotationsToAdd];
}

- (void) updateRadarSizes
{
    for (Radar * radar in self.mapView.annotations)
    {
        if([radar isKindOfClass:[Radar class]])
        {
            RadarAnnotationView * radarView = (RadarAnnotationView *)[self.mapView viewForAnnotation:radar];
            CGSize radarSize = [self.mapView convertRegion:radar.radarRegion toRectToView:radarView].size;
            radarView.bounds = (CGRect){CGPointZero, radarSize};
        }
    }
}

/****************************************************************************/
#pragma mark Actions

- (void) addRadar:(UILongPressGestureRecognizer*)longPressRecognizer
{
    switch (longPressRecognizer.state)
    {
        case UIGestureRecognizerStatePossible:
            break;
            
        case UIGestureRecognizerStateBegan:
            self.droppedRadar = [Radar insertInManagedObjectContext:self.model.moc];
            self.droppedRadar.manualRadarValue = YES;
            // just use a timestamp as the id
            long long identifier = 100*[NSDate timeIntervalSinceReferenceDate];
            self.droppedRadar.identifier = [NSString stringWithFormat:@"%lld",identifier];
            [self.mapView addAnnotation:self.droppedRadar];
            self.droppedRadar.coordinate = [self.mapView convertPoint:[longPressRecognizer locationInView:self.mapView]
                                                 toCoordinateFromView:self.mapView];
            [self performSelector:@selector(selectDroppedRadar) withObject:nil afterDelay:.2]; // Strangely, the mapview does not return the annotation view before a delay
            break;
        case UIGestureRecognizerStateChanged:
            self.droppedRadar.coordinate = [self.mapView convertPoint:[longPressRecognizer locationInView:self.mapView]
                                                 toCoordinateFromView:self.mapView];
            break;
        case UIGestureRecognizerStateEnded:
            [[self.mapView viewForAnnotation:self.droppedRadar] setDragState:MKAnnotationViewDragStateEnding animated:YES];
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self.mapView removeAnnotation:self.droppedRadar];
            [self.model.moc deleteObject:self.droppedRadar];
            self.droppedRadar = nil;
            break;
    }
}

- (void) selectDroppedRadar
{
    [self.mapView selectAnnotation:self.droppedRadar animated:YES];
    [[self.mapView viewForAnnotation:self.droppedRadar] setDragState:MKAnnotationViewDragStateStarting animated:YES];
}

- (void) refreshStation:(Station*)station
{
    [station refresh];
}

- (void) zoomInRegion:(Region*)region
{
    MKCoordinateRegion cregion = [self.mapView regionThatFits:region.coordinateRegion];
    CLLocationDistance meters = [[NSUserDefaults standardUserDefaults] doubleForKey:@"MapRegionZoomDistance"];
    cregion = MKCoordinateRegionMakeWithDistance(cregion.center, meters, meters);
	[self.mapView setRegion:cregion animated:YES];
}

- (void) showRadarMenu:(Radar*)radar
{
    [self becomeFirstResponder];
    UIMenuController * menu = [UIMenuController sharedMenuController];
    
    CGPoint point = [self.mapView convertCoordinate:radar.coordinate toPointToView:self.mapView];
    [menu setTargetRect:(CGRect){point,CGSizeZero} inView:self.mapView];
    [menu setMenuVisible:YES animated:YES];
}

- (void) delete:(id)sender // From UIMenuController
{
    for (Radar * radar in self.mapView.selectedAnnotations)
    {
        if([radar isKindOfClass:[Radar class]])
        {
            [self.mapView removeAnnotation:radar];
            [self.model.moc deleteObject:radar];
        }
    }
}

- (void) switchMode:(UISegmentedControl*)sender
{
    self.stationMode = sender.selectedSegmentIndex;

    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        StationAnnotationView * stationAV = (StationAnnotationView*)[self.mapView viewForAnnotation:annotation];
        if([stationAV isKindOfClass:[StationAnnotationView class]])
            stationAV.mode = self.stationMode;
    }
}

/****************************************************************************/
#pragma mark -

- (void) setAnnotationsHidden:(BOOL)hidden
{
    for (id annotation in self.mapView.annotations) 
        [self.mapView viewForAnnotation:annotation].hidden = hidden;
}

/****************************************************************************/
#pragma mark -

- (void) modelUpdated:(NSNotification*) note
{
    if([note.userInfo[VelibModelNotifications.keys.dataChanged] boolValue])
        [self reloadData];
}

/****************************************************************************/
#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([MapVC class])) {
        if(object == [NSUserDefaults standardUserDefaults] && [keyPath isEqualToString:@"RadarDistance"])
            [self updateRadarSizes];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
