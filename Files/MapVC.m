//
//  MapVC.m
//  Bicyclette
//
//  Created by Nicolas on 04/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "MapVC.h"
#import "BicycletteApplicationDelegate.h"
#import "BicycletteCity+Update.h"
#import "Station+Update.h"
#import "TransparentToolbar.h"
#import "CollectionsAdditions.h"
#import "RegionAnnotationView.h"
#import "StationAnnotationView.h"
#import "DrawingCache.h"
#import "MKMapView+AttributionLogo.h"
#import "MapVC+DebugScreenshots.h"
#import "FanContainerViewController.h"
#import "MapViewScaleView.h"
#import "GeofencesMonitor.h"
#import "Style.h"
#import "MapVC+DebugScreenshots.h"

@interface MapVC()
// UI
@property MKMapView * mapView;
@property UIToolbar * mapVCToolbar; // Do not use the system toolbal to prevent its height from changing
@property MKUserTrackingBarButtonItem * userTrackingButton;
@property UISegmentedControl * modeControl;
@property MapViewScaleView * scaleView;

@property StationAnnotationMode stationMode;
@property BOOL shouldZoomToUserWhenLocationFound;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateBegan object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateGotNewData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateSucceeded object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];

    _drawingCache = [DrawingCache new];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setController:(CitiesController *)controller_
{
    [_controller removeObserver:self forKeyPath:@"currentCity" context:(__bridge void *)([self class])];
    _controller = controller_;
    [_controller addObserver:self forKeyPath:@"currentCity" options:NSKeyValueObservingOptionInitial context:(__bridge void *)([self class])];
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
    CGRect mapViewFrame, toolBarFrame, frameAboveToolbar;
    CGRectDivide(self.view.bounds, &toolBarFrame, &frameAboveToolbar, kToolbarHeight, CGRectMaxYEdge);
    mapViewFrame = self.view.bounds;

    // Create mapview
    self.mapView = [[MKMapView alloc]initWithFrame:mapViewFrame];
    [self.view addSubview:self.mapView];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.delegate = self;
    
    // prepare toolbar items
    self.userTrackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    
    self.modeControl = [[UISegmentedControl alloc] initWithItems:@[ NSLocalizedString(@"BIKE", nil), NSLocalizedString(@"PARKING", nil) ]];
    [self.modeControl addTarget:self action:@selector(switchMode:) forControlEvents:UIControlEventValueChanged];
    self.modeControl.selectedSegmentIndex = self.stationMode;
    UIBarButtonItem * modeItem = [[UIBarButtonItem alloc] initWithCustomView:self.modeControl];
    modeItem.width = 160;
    
    // create toolbar
    self.mapVCToolbar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
    [self.view addSubview:self.mapVCToolbar];
    self.mapVCToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.mapVCToolbar.items = @[self.userTrackingButton,
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
    modeItem,
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        self.mapVCToolbar.translucent = YES; // means transparent actually

    // Add Scale
    CGRect scaleFrame = frameAboveToolbar;
    
    CGRect nothing;
    CGFloat scaleViewMargin = 9;
    CGFloat scaleViewWidth = 100;
    CGFloat scaleViewHeight = 13;
    CGRectEdge xEdge, yEdge;
    UIViewAutoresizing resizingMask;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        xEdge = CGRectMinXEdge;
        yEdge = CGRectMinYEdge;
        resizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        CGRectDivide(scaleFrame, &nothing, &scaleFrame, [[UIScreen mainScreen] applicationFrame].origin.y, CGRectMinYEdge);
    }
    else
    {
        xEdge = CGRectMaxXEdge;
        yEdge = CGRectMaxYEdge;
        resizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    }

    // Margins
    CGRectDivide(scaleFrame, &nothing, &scaleFrame, scaleViewMargin, xEdge);
    CGRectDivide(scaleFrame, &nothing, &scaleFrame, scaleViewMargin, yEdge);
    // Contents
    CGRectDivide(scaleFrame, &scaleFrame, &nothing, scaleViewWidth, xEdge);
    CGRectDivide(scaleFrame, &scaleFrame, &nothing, scaleViewHeight, yEdge);

    self.scaleView = [[MapViewScaleView alloc] initWithFrame:scaleFrame];
    self.scaleView.autoresizingMask = resizingMask;
    [self.view addSubview:self.scaleView];
    self.scaleView.mapView = self.mapView;
    
    [self forceFrontmost];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView relocateAttributionLogoIfNecessary];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
#if SCREENSHOTS
    // Debug for screenshot (Default.png)
    [self takeScreenshots];
#endif
    
    self.shouldZoomToUserWhenLocationFound = YES;
}

- (void) appDidBecomeActive
{
    self.shouldZoomToUserWhenLocationFound = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([MapVC class]))
    {
        if(object==self.controller && [keyPath isEqualToString:@"currentCity"])
        {
            [self updateModeControl];
            if(self.controller.currentCity)
                [self showTitle:self.controller.currentCity.title
                                subtitle:nil
                                  sticky:NO];
            else
                [self dismissTitle];
        }
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void) cityDataUpdated:(NSNotification*)note
{
    if(note.object==self.controller.currentCity && [self isVisibleViewController])
    {
        if([note.name isEqualToString:BicycletteCityNotifications.updateBegan])
            [self showTitle:self.controller.currentCity.title
                            subtitle:[NSString stringWithFormat:NSLocalizedString(@"UPDATING : FETCHING", nil)]
                              sticky:YES];
        else if([note.name isEqualToString:BicycletteCityNotifications.updateGotNewData])
            [self showTitle:self.controller.currentCity.title
                            subtitle:[NSString stringWithFormat:NSLocalizedString(@"UPDATING : PARSING", nil)]
                              sticky:YES];
        else if([note.name isEqualToString:BicycletteCityNotifications.updateSucceeded])
            [self showTitle:self.controller.currentCity.title
                            subtitle:[NSString stringWithFormat:NSLocalizedString(@"UPDATING : COMPLETED", nil)]
                              sticky:NO];
    }
}

- (void) canRequestLocation
{
    self.mapView.showsUserLocation = YES;
}

- (void) updateModeControl
{
    if(self.controller.currentCity==nil || [self.controller.currentCity canShowFreeSlots]) {
        self.modeControl.hidden = NO;
    } else {
        self.modeControl.hidden = YES;
        self.stationMode = StationAnnotationModeBikes;
    }
}

/****************************************************************************/
#pragma mark Rotation Support

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.mapView relocateAttributionLogoIfNecessary];
}

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

- (void) controller:(CitiesController*)controller selectAnnotation:(id<MKAnnotation>)annotation_
{
    if(annotation_)
        [self.mapView selectAnnotation:annotation_ animated:YES];
    else
    {
        for (id<MKAnnotation>annotation in [self.mapView selectedAnnotations]) {
            [self.mapView deselectAnnotation:annotation animated:YES];
        }
    }
}

- (void) controller:(CitiesController*)controller setAnnotations:(NSArray*)newAnnotations overlays:(NSArray*)newOverlays
{
    NSArray * oldAnnotations = [self.mapView.annotations arrayByRemovingObjectsInArray:@[ self.mapView.userLocation ]];
    [self.mapView removeAnnotations:[oldAnnotations arrayByRemovingObjectsInArray:newAnnotations]];
    [self.mapView addAnnotations:[newAnnotations arrayByRemovingObjectsInArray:oldAnnotations]];
    
    NSArray * oldOverlays = self.mapView.overlays;
    [self.mapView removeOverlays:[oldOverlays arrayByRemovingObjectsInArray:newOverlays]];
    [self.mapView addOverlays:[newOverlays arrayByRemovingObjectsInArray:oldOverlays]];
}

/****************************************************************************/
#pragma mark MapView Delegate

- (void) forceFrontmost
{
    // Force the userlocation annotation to be frontmost
    UIView * locationView = [self.mapView viewForAnnotation:self.mapView.userLocation];
    [locationView.superview bringSubviewToFront:locationView];

    [self performSelector:@selector(forceFrontmost) withObject:nil afterDelay:.5];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    // "animated" means "not dragged by the user"
    // I only want to know that the mapview is being manipulated by the user.
    if(!animated) {
        self.controller.mapViewIsMoving = YES;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.controller.mapViewIsMoving = NO;
    [self.controller regionDidChange:self.mapView.region];
    [self.scaleView setNeedsDisplay];
    self.shouldZoomToUserWhenLocationFound = NO;
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
	else if([annotation isKindOfClass:[BicycletteCity class]])
	{
        BOOL hasFences = [self.controller cityHasFences:(BicycletteCity*)annotation];
        NSString * reuseID = hasFences ? @"purplepin" : @"redpin";
        MKPinAnnotationView * pinAV = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseID];
        if(nil==pinAV)
            pinAV = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseID];
        else
            pinAV.annotation = annotation;
        if([[NSUserDefaults standardUserDefaults] doubleForKey:@"MapVC.showCityCallout"])
            pinAV.canShowCallout = YES;
        pinAV.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        pinAV.pinColor = hasFences ? MKPinAnnotationColorPurple : MKPinAnnotationColorRed;
        return pinAV;
	}
	return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(Geofence*)fence
{
    NSAssert([fence isKindOfClass:[Geofence class]], nil);
    MKCircleRenderer * circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:fence];
    circleRenderer.fillColor = kFenceBackgroundColor;
    circleRenderer.strokeColor = kAnnotationDash1Color;
    circleRenderer.lineWidth = kDashedBorderWidth;
    circleRenderer.lineDashPattern = @[@(kDashLength), @(kDashLength)];

    return circleRenderer;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if( self.shouldZoomToUserWhenLocationFound )
    {
        // This is the first location update we get : if the user hasn't moved the map, and he is physically inside a city, let's zoom.
        BicycletteCity * nearestCity = (BicycletteCity*)[self.controller.cities nearestLocatableFrom:userLocation.location];
        if([[nearestCity regionContainingData] containsCoordinate:userLocation.location.coordinate])
        {
            [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        }
    }
    self.shouldZoomToUserWhenLocationFound = NO;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	if([view.annotation isKindOfClass:[BicycletteCity class]]) {
        if(![[NSUserDefaults standardUserDefaults] doubleForKey:@"MapVC.showCityCallout"])
            [self.controller selectCity:(BicycletteCity*)view.annotation];
    } else if([view.annotation isKindOfClass:[Region class]]) {
		[self zoomInRegion:(Region*)view.annotation];
    } else if([view.annotation isKindOfClass:[Station class]]) {
        if([self.controller.currentCity canUpdateIndividualStations])
            [(Station*)view.annotation updateWithCompletionBlock:nil];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(StationAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if([view isKindOfClass:[StationAnnotationView class]]) {
        NSAssert([view.annotation isKindOfClass:[Station class]],nil);
        Station * station = (Station*)view.annotation;
        [self.controller switchStarredStation:station];
    } else if([view.annotation isKindOfClass:[BicycletteCity class]]) {
        [self.controller selectCity:(BicycletteCity*)view.annotation];
    }
}

/****************************************************************************/
#pragma mark Actions

- (void) zoomInRegion:(Region*)region
{
    MKCoordinateRegion cregion = [self.mapView regionThatFits:region.coordinateRegion];
    CLLocationDistance meters = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CitiesController.MapRegionZoomDistance"];
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

/****************************************************************************/
#pragma mark Banner

- (void) showTitle:(NSString*)title subtitle:(NSString*)subtitle sticky:(BOOL)sticky
{
    self.navigationItem.title = title;
    self.navigationItem.prompt = subtitle;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissTitle) object:nil];
    
#if ! SCREENSHOTS
    if(!sticky)
        [self performSelector:@selector(dismissTitle) withObject:nil afterDelay:3];
#endif
}

- (void) dismissTitle
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

@end
