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
#import "NSArrayAdditions.h"
#import "RegionAnnotationView.h"
#import "StationAnnotationView.h"
#import "DrawingCache.h"
#import "Radar.h"
#import "RadarAnnotationView.h"
#import "RadarUpdateQueue.h"
#import "MKMapView+AttributionLogo.h"
#import "MapVC+DebugScreenshots.h"
#import "NSMutableArray+Locatable.h"

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
@property (nonatomic) BicycletteCity * currentCity;
@property MKCoordinateRegion referenceRegion;
@property (nonatomic) MapLevel level;
@property StationAnnotationMode stationMode;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityUpdated:)
                                                 name:BicycletteCityNotifications.updateSucceeded object:nil];
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

    // reload data
    [self reloadData];
    
    // Debug for screenshot (Default.png)
    if([NSUserDefaults.standardUserDefaults boolForKey:@"DebugScreenshotForDefault"])
    {
        self.modeControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    }
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

- (void) viewDidAppear:(BOOL)animated
{
    // Debug for screenshot (Default.png)
    if([NSUserDefaults.standardUserDefaults boolForKey:@"DebugScreenshotForDefault"])
        [self takeScreenshotForDefaultAndExit];
    
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"DebugScreenshotForITC"])
        [self takeScreenshotsForITCAndExit];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.mapView relocateAttributionLogoIfNecessary];
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
	self.mapView.region = region;

    // Debug for screenshot (Default.png)
    if([NSUserDefaults.standardUserDefaults boolForKey:@"DebugScreenshotForDefault"])
        self.mapView.region = (MKCoordinateRegion){{0.,0.},{20.,20.}};

    [self addAndRemoveMapAnnotations];
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

- (void) setLevel:(MapLevel)level_
{
    if(_level==level_)
        return;
    
    _level = level_;
    if(self.level == MapLevelNone)
        self.currentCity = nil;
    else
    {
        CLLocationCoordinate2D centerCoord = self.mapView.region.center;
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

    // Keep the screen center Radar centered
    self.currentCity.screenCenterRadar.coordinate = [self.mapView convertPoint:self.mapView.center toCoordinateFromView:self.mapView.superview];
    // And make it as big as the screen, but only if the stations are actually visible
    if(self.level==MapLevelStationsAndRadars)
        self.currentCity.screenCenterRadar.customRadarSpan = self.mapView.region.span;
    else
        self.currentCity.screenCenterRadar.customRadarSpan = MKCoordinateSpanMake(0, 0);

    // In the same vein, only set the updater reference location if we're down enough
    if(self.level==MapLevelRegionsAndRadars || self.level==MapLevelStationsAndRadars)
        self.currentCity.updaterQueue.referenceLocation = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    else
        self.currentCity.updaterQueue.referenceLocation = nil;
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

    if([view.annotation isKindOfClass:[Station class]])
    {
        UIButton *callout = [UIButton buttonWithType:UIButtonTypeCustom];
        callout.frame = (CGRect){CGPointZero, [UIImage imageNamed:@"Favorite_off.png"].size};
        [callout setImage:[UIImage imageNamed:@"Favorite_off.png"] forState:UIControlStateNormal];
        [callout setImage:[UIImage imageNamed:@"Favorite_on.png"] forState:UIControlStateSelected];
        [callout addTarget:self action:@selector(toogleFavorite:) forControlEvents:UIControlEventTouchUpInside];
        callout.selected = [(Station*)view.annotation isFavoriteValue];
        view.rightCalloutAccessoryView = callout;
    }
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
    CLLocationCoordinate2D oldCoord = [self.currentCity userLocationRadar].coordinate;
    CLLocationCoordinate2D newCoord = userLocation.coordinate;
    if(oldCoord.latitude != newCoord.latitude || oldCoord.longitude != newCoord.longitude)
        [self.currentCity userLocationRadar].coordinate = newCoord;

    if(oldCoord.latitude == 0 && oldCoord.longitude == 0
       && newCoord.latitude != 0 && newCoord.longitude != 0
       && newCoord.latitude > self.referenceRegion.center.latitude - self.referenceRegion.span.latitudeDelta
       && newCoord.latitude < self.referenceRegion.center.latitude + self.referenceRegion.span.latitudeDelta
       && newCoord.longitude > self.referenceRegion.center.longitude - self.referenceRegion.span.longitudeDelta
       && newCoord.longitude < self.referenceRegion.center.longitude + self.referenceRegion.span.longitudeDelta)
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void) addAndRemoveMapAnnotations
{
    // Debug for screenshot (Default.png)
    if([NSUserDefaults.standardUserDefaults boolForKey:@"DebugScreenshotForDefault"])
        return;
    
    NSArray * oldAnnotations = self.mapView.annotations;
    oldAnnotations = [oldAnnotations arrayByRemovingObjectsInArray:@[ self.mapView.userLocation ]];
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

        // Favorite Stations
        NSFetchRequest * stationsRequest = [NSFetchRequest new];
		[stationsRequest setEntity:[Station entityInManagedObjectContext:self.currentCity.moc]];
        MKCoordinateRegion mapRegion = self.mapView.region;
		stationsRequest.predicate = [NSPredicate predicateWithFormat:@"isFavorite = YES AND latitude>%f AND latitude<%f AND longitude>%f AND longitude<%f",
                                     mapRegion.center.latitude - mapRegion.span.latitudeDelta/2,
                                     mapRegion.center.latitude + mapRegion.span.latitudeDelta/2,
                                     mapRegion.center.longitude - mapRegion.span.longitudeDelta/2,
                                     mapRegion.center.longitude + mapRegion.span.longitudeDelta/2];
        NSArray *newStations = [self.currentCity.moc executeFetchRequest:stationsRequest error:NULL];
        [newAnnotations addObjectsFromArray:newStations];
        NSArray *favoriteRegions = [[NSSet setWithArray:[newStations valueForKey:@"region"]] allObjects];
        [newAnnotations removeObjectsInArray:favoriteRegions];
    }
    
    if (self.level == MapLevelRegionsAndRadars || self.level == MapLevelStationsAndRadars)
    {
        // Radars
        NSFetchRequest * radarsRequest = [NSFetchRequest new];
        [radarsRequest setEntity:[Radar entityInManagedObjectContext:self.currentCity.moc]];
        NSMutableArray * allRadars = [[self.currentCity.moc executeFetchRequest:radarsRequest error:NULL] mutableCopy];
        // do not add an annotation for screenCenterRadar, it's handled separately.
        [allRadars removeObject:self.currentCity.screenCenterRadar];
        // only add the userLocationRadar if it's actually here
        if(self.mapView.userLocation.coordinate.latitude==0.0)
            [allRadars removeObject:self.currentCity.userLocationRadar];
        [newAnnotations addObjectsFromArray:[newAnnotations arrayByAddingObjectsFromArray:allRadars]];
    }

    if (self.level == MapLevelStationsAndRadars)
    {
        // Stations
        NSFetchRequest * stationsRequest = [NSFetchRequest new];
		[stationsRequest setEntity:[Station entityInManagedObjectContext:self.currentCity.moc]];
        MKCoordinateRegion mapRegion = self.mapView.region;
		stationsRequest.predicate = [NSPredicate predicateWithFormat:@"latitude>%f AND latitude<%f AND longitude>%f AND longitude<%f",
							 mapRegion.center.latitude - mapRegion.span.latitudeDelta/2,
                             mapRegion.center.latitude + mapRegion.span.latitudeDelta/2,
                             mapRegion.center.longitude - mapRegion.span.longitudeDelta/2,
                             mapRegion.center.longitude + mapRegion.span.longitudeDelta/2];
        [newAnnotations addObjectsFromArray:[self.currentCity.moc executeFetchRequest:stationsRequest error:NULL]];
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
    if (self.level != MapLevelRegionsAndRadars && self.level != MapLevelStationsAndRadars)
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
            [self.currentCity.moc deleteObject:self.droppedRadar];
            self.droppedRadar = nil;
            break;
    }
}

- (void) createRadarAtPoint:(CGPoint)pointInMapView
{
    self.droppedRadar = [Radar insertInManagedObjectContext:self.currentCity.moc];
    self.droppedRadar.manualRadarValue = YES;
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

- (void) zoomInStation:(Station*)station
{
    self.currentCity = station.city;
    CLLocationDistance meters = [[NSUserDefaults standardUserDefaults] doubleForKey:@"MapRegionZoomDistance"];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(station.coordinate, meters, meters);
	[self.mapView setRegion:region animated:YES];
    [self.mapView selectAnnotation:station animated:YES];
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
            [self.currentCity.moc deleteObject:radar];
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

#pragma mark Actions

- (void) toogleFavorite:(id)sender
{
    if (self.mapView.selectedAnnotations.count) {
        Station *station = [self.mapView.selectedAnnotations objectAtIndex:0];
        station.isFavoriteValue = !station.isFavoriteValue;
        [(UIButton*)sender setSelected:[station isFavoriteValue]];
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

- (void) cityUpdated:(NSNotification*) note
{
    if([note.userInfo[BicycletteCityNotifications.keys.dataChanged] boolValue])
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
