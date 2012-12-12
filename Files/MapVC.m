//
//  MapVC.m
//  Bicyclette
//
//  Created by Nicolas on 04/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "MapVC.h"
#import "BicycletteApplicationDelegate.h"
#import "BicycletteCity.h"
#import "Station.h"
#import "Region.h"
#import "TransparentToolbar.h"
#import "CollectionsAdditions.h"
#import "RegionAnnotationView.h"
#import "StationAnnotationView.h"
#import "DrawingCache.h"
#import "Radar.h"
#import "RadarAnnotationView.h"
#import "LocalUpdateQueue.h"
#import "MKMapView+AttributionLogo.h"
#import "MapVC+DebugScreenshots.h"

@interface MapVC() <MKMapViewDelegate>
// UI
@property MKMapView * mapView;
@property UIToolbar * mapVCToolbar; // Do not use the system toolbal to prevent its height from changing
@property MKUserTrackingBarButtonItem * userTrackingButton;
@property UISegmentedControl * modeControl;

@property StationAnnotationMode stationMode;
@property CLLocationCoordinate2D userCoordinates;

// Radar creation
@property Radar * droppedRadar;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canRequestLocation)
                                                 name:BicycletteCityNotifications.canRequestLocation object:nil];
    
    _drawingCache = [DrawingCache new];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

/****************************************************************************/
#pragma mark View Cycle

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

    self.userCoordinates = CLLocationCoordinate2DMake(0, 0);
    // reload data
    [self.controller reloadData];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView relocateAttributionLogoIfNecessary];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([MapVC class]))
        [self updateRadarSizes];
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void) canRequestLocation
{
    self.mapView.showsUserLocation = YES;
}

/****************************************************************************/
#pragma mark Rotation Support

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.mapView relocateAttributionLogoIfNecessary];
}

// iOS 5
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

// iOS 6
- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

/****************************************************************************/
#pragma mark CitiesControllerDelegate

- (void) controller:(CitiesController*)controller setRegion:(MKCoordinateRegion)region
{
    [self.mapView setRegion:region animated:YES];
}

- (void) controller:(CitiesController*)controller selectAnnotation:(id<MKAnnotation>)annotation
{
    [self.mapView selectAnnotation:annotation animated:YES];
}

- (MKCoordinateRegion)regionForController:(CitiesController*)controller
{
    return self.mapView.region;
}

- (void) controller:(CitiesController*)controller setAnnotations:(NSArray*)newAnnotations
{
    NSArray * oldAnnotations = self.mapView.annotations;
    oldAnnotations = [oldAnnotations arrayByRemovingObjectsInArray:@[ self.mapView.userLocation ]];
    
    NSArray * annotationsToRemove = [oldAnnotations arrayByRemovingObjectsInArray:newAnnotations];
    NSArray * annotationsToAdd = [newAnnotations arrayByRemovingObjectsInArray:oldAnnotations];
    
    [self.mapView removeAnnotations:annotationsToRemove];
    [self.mapView addAnnotations:annotationsToAdd];
}

/****************************************************************************/
#pragma mark MapView Delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self.controller regionDidChange:self.mapView.region];
    [self updateRadarSizes];
}

- (void) updateRadarSizes
{
    for (Radar * radar in [self.mapView.annotations filteredArrayWithValue:[Radar class] forKeyPath:@"class"])
    {
        RadarAnnotationView * radarView = (RadarAnnotationView *)[self.mapView viewForAnnotation:radar];
        radarView.bounds = (CGRect){CGPointZero, [self.mapView convertRegion:radar.radarRegion toRectToView:radarView].size};
    }
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

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D newCoord = userLocation.coordinate;
    MKCoordinateRegion referenceRegion = self.controller.referenceRegion;
    if(self.userCoordinates.latitude == 0 && self.userCoordinates.longitude == 0
       && newCoord.latitude != 0 && newCoord.longitude != 0
       && newCoord.latitude > referenceRegion.center.latitude - referenceRegion.span.latitudeDelta
       && newCoord.latitude < referenceRegion.center.latitude + referenceRegion.span.latitudeDelta
       && newCoord.longitude > referenceRegion.center.longitude - referenceRegion.span.longitudeDelta
       && newCoord.longitude < referenceRegion.center.longitude + referenceRegion.span.longitudeDelta)
    {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        self.userCoordinates = newCoord;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	if([view.annotation isKindOfClass:[BicycletteCity class]])
        [self.mapView setRegion:[((BicycletteCity*)view.annotation) regionContainingData] animated:YES];
    else if([view.annotation isKindOfClass:[Region class]])
		[self zoomInRegion:(Region*)view.annotation];
    else if([view.annotation isKindOfClass:[Station class]])
        [(Station*)view.annotation updateWithCompletionBlock:nil];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    NSAssert([view.annotation isKindOfClass:[Radar class]],nil);

    [self.mapView selectAnnotation:view.annotation animated:YES];
    if(newState==MKAnnotationViewDragStateCanceling)
        [self showDeleteRadarMenu:(Radar*)view.annotation];
}

/****************************************************************************/
#pragma mark UILongPressGestureRecognizer Action

- (void) addRadar:(UILongPressGestureRecognizer*)longPressRecognizer
{
    if (self.controller.currentCity == nil)
        return; // prevent creating radars from high level
    
    CGPoint pointInMapView = [longPressRecognizer locationInView:self.mapView];
    switch (longPressRecognizer.state)
    {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
        {
            [self.controller.currentCity performUpdates:^(NSManagedObjectContext *updateContext) {
                Radar * radar = [Radar insertInManagedObjectContext:updateContext];
                // just use a timestamp as the id
                radar.identifier = [NSString stringWithFormat:@"%lld",(long long)(100*[NSDate timeIntervalSinceReferenceDate])];
                radar.coordinate = [self.mapView convertPoint:pointInMapView
                                         toCoordinateFromView:self.mapView];
            } saveCompletion:^(NSNotification *contextDidSaveNotification) {
                NSManagedObjectID * radarID = [[[contextDidSaveNotification userInfo][NSInsertedObjectsKey] anyObject] objectID];
                self.droppedRadar = (Radar*)[self.controller.currentCity.moc objectWithID:radarID];
                [self.mapView addAnnotation:self.droppedRadar];
                [self performSelector:@selector(selectDroppedRadar) withObject:nil afterDelay:.2]; // Strangely, the mapview does not return the annotation view before a delay
            }];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            [self.controller.currentCity performUpdates:^(NSManagedObjectContext *updateContext) {
                Radar * radar = (Radar*)[updateContext objectWithID:self.droppedRadar.objectID];
                radar.coordinate = [self.mapView convertPoint:pointInMapView
                                                     toCoordinateFromView:self.mapView];
            } saveCompletion:nil];
            break;
        }
        case UIGestureRecognizerStateEnded:
            [[self.mapView viewForAnnotation:self.droppedRadar] setDragState:MKAnnotationViewDragStateEnding animated:YES];
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self.mapView removeAnnotation:self.droppedRadar];
            [self.controller.currentCity performUpdates:^(NSManagedObjectContext *updateContext) {
                [updateContext deleteObject:[updateContext objectWithID:self.droppedRadar.objectID]];
            } saveCompletion:nil];
            self.droppedRadar = nil;
            break;
    }
}

- (void) selectDroppedRadar
{
    [self.mapView selectAnnotation:self.droppedRadar animated:YES];
    [[self.mapView viewForAnnotation:self.droppedRadar] setDragState:MKAnnotationViewDragStateStarting animated:YES];
}

/****************************************************************************/
#pragma mark UIMenuController

- (BOOL) canBecomeFirstResponder
{
    return YES;
}

- (void) showDeleteRadarMenu:(Radar*)radar
{
    [self becomeFirstResponder];
    UIMenuController * menu = [UIMenuController sharedMenuController];
    
    CGPoint point = [self.mapView convertCoordinate:radar.coordinate toPointToView:self.mapView];
    [menu setTargetRect:(CGRect){point,CGSizeZero} inView:self.mapView];
    [menu setMenuVisible:YES animated:YES];
}

- (void) delete:(id)sender // From UIMenuController
{
    Radar * radar = [self.mapView.selectedAnnotations lastObject];
    NSAssert([radar isKindOfClass:[Radar class]],nil);

    [self.mapView removeAnnotation:radar];
    [self.controller.currentCity performUpdates:^(NSManagedObjectContext *updateContext) {
        [updateContext deleteObject:[updateContext objectWithID:radar.objectID]];
    } saveCompletion:nil];
}

/****************************************************************************/
#pragma mark Actions

- (void) zoomInRegion:(Region*)region
{
    MKCoordinateRegion cregion = [self.mapView regionThatFits:region.coordinateRegion];
    CLLocationDistance meters = [[NSUserDefaults standardUserDefaults] doubleForKey:@"MapRegionZoomDistance"];
    cregion = MKCoordinateRegionMakeWithDistance(cregion.center, meters, meters);
	[self.mapView setRegion:cregion animated:YES];
}

- (void) switchMode:(UISegmentedControl*)sender
{
    self.stationMode = sender.selectedSegmentIndex;
    for (id<MKAnnotation> annotation in [self.mapView.annotations filteredArrayWithValue:[Station class] forKeyPath:@"class"]) {
        StationAnnotationView * stationAV = (StationAnnotationView*)[self.mapView viewForAnnotation:annotation];
        stationAV.mode = self.stationMode;
    }
}

@end
