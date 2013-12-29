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
#import "CollectionsAdditions.h"
#import "StationAnnotationView.h"
#import "MKMapView+AttributionLogo.h"
#import "MapVC+DebugScreenshots.h"
#import "MapViewScaleView.h"
#import "GeofencesMonitor.h"
#import "Style.h"
#import "MapVC+DebugScreenshots.h"
#import "CityAnnotationView.h"
#import "MKUtilities.h"
#import "CityOverlayRenderer.h"
#import "CLRegion+CircularRegionCompatibility.h"
#import "PrefsVC.h"
#import "UIBarButtonItem+BICMargins.h"

@interface MapVC()
// UI
@property MKMapView * mapView;
@property MKUserTrackingBarButtonItem * userTrackingButton;
@property UISegmentedControl * modeControl;
@property UIBarButtonItem * infoButton;
@property MapViewScaleView * scaleView;

@property StationAnnotationMode stationMode;
@property BOOL shouldZoomToUserWhenLocationFound;

@end


/****************************************************************************/
#pragma mark -

@implementation MapVC

+ (instancetype) mapVCWithController:(CitiesController*)controller_
{
    MapVC * mapVC = [self new];
    mapVC.controller = controller_;
    return mapVC;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canRequestLocation)
                                                     name:BicycletteCityNotifications.canRequestLocation object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateBegan object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateGotNewData object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateSucceeded object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setController:(CitiesController *)controller_
{
    [_controller removeObserver:self forKeyPath:@"currentCity" context:__FILE__];
    _controller = controller_;
    [_controller addObserver:self forKeyPath:@"currentCity" options:0 context:__FILE__];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == __FILE__ && object==self.controller && [keyPath isEqualToString:@"currentCity"]) {
        [self updateModeControl];
        [self updateTitle];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.showsBuildings = NO;
    self.mapView.scrollEnabled = YES;
    self.mapView.delegate = self;
    
    // prepare toolbar items
    self.userTrackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    
    self.modeControl = [[UISegmentedControl alloc] initWithItems:@[ NSLocalizedString(@"BIKE", nil), NSLocalizedString(@"PARKING", nil) ]];
    [self.modeControl addTarget:self action:@selector(switchMode:) forControlEvents:UIControlEventValueChanged];
    self.modeControl.selectedSegmentIndex = self.stationMode;
    UIBarButtonItem * modeItem = [[UIBarButtonItem alloc] initWithCustomView:self.modeControl];
    modeItem.width = 160;
    
    UIButton * iButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [iButton addTarget:self action:@selector(showPrefsVC) forControlEvents:UIControlEventTouchUpInside];
    self.infoButton = [[UIBarButtonItem alloc] initWithCustomView:iButton];
    
    // create toolbar
    self.toolbarItems = @[[UIBarButtonItem bic_negativeMarginButtonItem],
                          self.userTrackingButton,
                          [UIBarButtonItem bic_flexibleMarginButtonItem],
                          modeItem,
                          [UIBarButtonItem bic_flexibleMarginButtonItem],
                          self.infoButton,
                          [UIBarButtonItem bic_negativeMarginButtonItem]];
    
    self.navigationController.toolbarHidden = NO;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        self.navigationController.toolbar.translucent = YES;
    
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
    
    // Navigation bar
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self updateTitle];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.mapView relocateAttributionLabelIfNecessary];
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

- (void) updateTitle
{
    if(self.controller.currentCity) {
        [self showTitle:self.controller.currentCity.title subtitle:nil sticky:NO];
    } else {
        [self dismissTitle];
    }
}

- (void) cityDataUpdated:(NSNotification*)note
{
    if(note.object==self.controller.currentCity) {
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
    [self.mapView relocateAttributionLabelIfNecessary];
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

    [[self.mapView rendererForOverlay:self.controller.currentCity] setNeedsDisplay];
}

/****************************************************************************/
#pragma mark MapView Delegate

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
	else if([annotation isKindOfClass:[Station class]])
	{
		StationAnnotationView * stationAV = (StationAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Station"];
		if(nil==stationAV) {
			stationAV = [[StationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Station"];
        }
        
        stationAV.mode = self.stationMode;
		return stationAV;
	}
	else if([annotation isKindOfClass:[BicycletteCity class]])
	{
        CityAnnotationView * pinAV = (CityAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
        if(nil==pinAV) {
            pinAV = [[CityAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        } else {
            pinAV.annotation = annotation;
        }
        return pinAV;
	}
	return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:[Geofence class]], nil) {
        MKCircleRenderer * circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        circleRenderer.fillColor = kFenceBackgroundColor;
        return circleRenderer;
    } else if ([overlay isKindOfClass:[BicycletteCity class]]) {
        CityOverlayRenderer * cityRenderer = [[CityOverlayRenderer alloc] initWithOverlay:overlay];
        cityRenderer.mode = self.stationMode;
        return cityRenderer;
    } else {
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if( self.shouldZoomToUserWhenLocationFound )
    {
        // This is the first location update we get : if the user hasn't moved the map, and he is physically inside a city, let's zoom.
        BicycletteCity * nearestCity = (BicycletteCity*)[self.controller.cities nearestLocatableFrom:userLocation.location];
        if([[nearestCity regionContainingData] bic_compat_containsCoordinate:userLocation.location.coordinate])
        {
            [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        }
    }
    self.shouldZoomToUserWhenLocationFound = NO;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	if([view.annotation isKindOfClass:[BicycletteCity class]]) {
        [mapView deselectAnnotation:view.annotation animated:NO];
        CGRect rect = CGRectInset([view bounds], -10.f, -10.f);
        MKCoordinateRegion region = [mapView convertRect:rect toRegionFromView:view];
        MKMapRect mapRect = BICMKMapRectForCoordinateRegion(region);
        NSSet * cities = [mapView annotationsInMapRect:mapRect];
        cities = [cities filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject isKindOfClass:[BicycletteCity class]];
        }]];
        if([cities count]>1) {
            CGRect rect2 = CGRectInset([view bounds], -20.f, -20.f);
            MKCoordinateRegion region2 = [mapView convertRect:rect2 toRegionFromView:view];
            [self.mapView setRegion:region2 animated:YES];
        } else {
            [self.controller selectCity:(BicycletteCity*)view.annotation];
        }
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
    }
}

/****************************************************************************/
#pragma mark Actions

- (void) switchMode:(UISegmentedControl*)sender
{
    self.stationMode = sender.selectedSegmentIndex;
    for (id<MKAnnotation> annotation in [self.mapView.annotations filteredArrayWithValue:[Station class] forKeyPath:@"class"]) {
        StationAnnotationView * stationAV = (StationAnnotationView*)[self.mapView viewForAnnotation:annotation];
        stationAV.mode = self.stationMode;
    }
    CityOverlayRenderer * cityRenderer = (CityOverlayRenderer *)[self.mapView rendererForOverlay:self.controller.currentCity];
    cityRenderer.mode = self.stationMode;
    [cityRenderer setNeedsDisplay];
}

- (void) showPrefsVC
{
    [self presentViewController:[PrefsVC prefsVCWithController:self.controller] animated:YES completion:nil];
}

// Banner

- (void) showTitle:(NSString*)title subtitle:(NSString*)subtitle sticky:(BOOL)sticky
{
    NSLog(@"show %@ %@ %d", title, subtitle, sticky);
    self.navigationItem.title = title;
    self.navigationItem.prompt = subtitle;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissTitle) object:nil];
    
#if ! SCREENSHOTS
    if(!sticky) {
        [self performSelector:@selector(dismissTitle) withObject:nil afterDelay:3];
    }
#endif
}

- (void) dismissTitle
{
    NSLog(@"dismiss");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

@end
