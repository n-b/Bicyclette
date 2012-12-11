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

    self.userCoordinates = CLLocationCoordinate2DMake(0, 0);
    // reload data
    [self.citiesController reloadData];
}

- (void) canRequestLocation
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

- (void) setRegion:(MKCoordinateRegion)region
{
    [self.mapView setRegion:region animated:YES];
}

- (void) selectAnnotation:(id<MKAnnotation>)annotation
{
    [self.mapView selectAnnotation:annotation animated:YES];
}

- (MKCoordinateRegion)region
{
    return self.mapView.region;
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
#pragma mark MapView Delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MKCoordinateRegion viewRegion = self.mapView.region;
    [self.citiesController regionDidChange:viewRegion];

    [self updateRadarSizes];

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
        [(Station*)view.annotation updateWithCompletionBlock:nil];
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
    CLLocationCoordinate2D newCoord = userLocation.coordinate;
    MKCoordinateRegion referenceRegion = self.citiesController.referenceRegion;
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


- (void) setAnnotations:(NSArray*)newAnnotations
{
    NSArray * oldAnnotations = self.mapView.annotations;
    oldAnnotations = [oldAnnotations arrayByRemovingObjectsInArray:@[ self.mapView.userLocation ]];

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
    if (self.citiesController.currentCity == nil)
        return; // prevent creating radars from high level
    
    switch (longPressRecognizer.state)
    {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            [self createRadarAtPoint:[longPressRecognizer locationInView:self.mapView]];
            break;
        case UIGestureRecognizerStateChanged:
            [self moveRadarAtPoint:[longPressRecognizer locationInView:self.mapView]];
            break;
        case UIGestureRecognizerStateEnded:
            [[self.mapView viewForAnnotation:self.droppedRadar] setDragState:MKAnnotationViewDragStateEnding animated:YES];
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self.mapView removeAnnotation:self.droppedRadar];
            [self.citiesController.currentCity.moc deleteObject:self.droppedRadar];
            self.droppedRadar = nil;
            break;
    }
}

- (void) createRadarAtPoint:(CGPoint)pointInMapView
{
    self.droppedRadar = [Radar insertInManagedObjectContext:self.citiesController.currentCity.moc];
    // just use a timestamp as the id
    long long identifier = 100*[NSDate timeIntervalSinceReferenceDate];
    self.droppedRadar.identifier = [NSString stringWithFormat:@"%lld",identifier];
    [self.mapView addAnnotation:self.droppedRadar];
    self.droppedRadar.coordinate = [self.mapView convertPoint:pointInMapView
                                         toCoordinateFromView:self.mapView];
    [self performSelector:@selector(selectDroppedRadar) withObject:nil afterDelay:.2]; // Strangely, the mapview does not return the annotation view before a delay
}

- (void) moveRadarAtPoint:(CGPoint)pointInMapView
{
    self.droppedRadar.coordinate = [self.mapView convertPoint:pointInMapView
                                         toCoordinateFromView:self.mapView];
}

- (void) selectDroppedRadar
{
    [self.mapView selectAnnotation:self.droppedRadar animated:YES];
    [[self.mapView viewForAnnotation:self.droppedRadar] setDragState:MKAnnotationViewDragStateStarting animated:YES];
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
            [self.citiesController.currentCity.moc deleteObject:radar];
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
