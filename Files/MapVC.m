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
#import "Model+Mapkit.h"
#import "NSArrayAdditions.h"
#import "VelibModel+Favorites.h"

typedef enum {
	MapModeNone = 0,
	MapModeRegions,
	MapModeStations
}  MapMode;

@interface MapVC() <MKMapViewDelegate>

// Outlets
@property MKMapView * mapView;
@property MKUserTrackingBarButtonItem * userTrackingButton;

@property MKCoordinateRegion referenceRegion;
@property (nonatomic) MapMode mode;

@end

/****************************************************************************/
#pragma mark -

@implementation MapVC 

@synthesize mapView, userTrackingButton;
@synthesize referenceRegion, mode;


- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteDidChange:) 
													 name:VelibModelNotifications.favoriteChanged object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

/****************************************************************************/
#pragma mark -

- (void) loadView
{
    self.mapView = [[MKMapView alloc]initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view = self.mapView;
    self.mapView.showsUserLocation = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.delegate = self;
    
    self.userTrackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navigationItem.leftBarButtonItem = self.userTrackingButton;
    
	self.referenceRegion = [self.mapView regionThatFits:BicycletteAppDelegate.model.regionContainingData];
	self.mapView.region = self.referenceRegion;
}


- (void) viewDidUnload
{
    self.userTrackingButton = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.mapView = nil;
    [super viewDidUnload];
}
/****************************************************************************/
#pragma mark MapView Delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	CLLocationDegrees modelSpan = self.referenceRegion.span.latitudeDelta;
	if(self.mapView.region.span.latitudeDelta>modelSpan/10.0f)
		self.mode = MapModeRegions;
	else
	{
		self.mode = MapModeStations;
		
		NSFetchRequest * request = [NSFetchRequest new];
		[request setEntity:[Station entityInManagedObjectContext:BicycletteAppDelegate.model.moc]];
        MKCoordinateRegion mapRegion = self.mapView.region;
		request.predicate = [NSPredicate predicateWithFormat:@"latitude>%f AND latitude<%f AND longitude>%f AND longitude<%f",
							 mapRegion.center.latitude - mapRegion.span.latitudeDelta, 
                             mapRegion.center.latitude + mapRegion.span.latitudeDelta,
                             mapRegion.center.longitude - mapRegion.span.longitudeDelta, 
                             mapRegion.center.longitude + mapRegion.span.longitudeDelta];

		NSArray * oldAnnotations = self.mapView.annotations;
		NSArray * newAnnotations = [BicycletteAppDelegate.model.moc executeFetchRequest:request error:NULL];
		
		NSMutableArray * annotationsToRemove = [oldAnnotations mutableCopy];
        [annotationsToRemove removeObjectsInArray:newAnnotations];
        [annotationsToRemove removeObject:self.mapView.userLocation];
		NSArray * annotationsToAdd = [newAnnotations arrayByRemovingObjectsInArray:oldAnnotations];

        NSLog(@"removing %d annotations, adding %d",[annotationsToRemove count], [annotationsToAdd count]);
		[self.mapView removeAnnotations:annotationsToRemove];
		[self.mapView addAnnotations:annotationsToAdd];
		
		NSArray * visibleFavorites = [newAnnotations filteredArrayWithSelector:@selector(isFavorite)];
		[visibleFavorites makeObjectsPerformSelector:@selector(refresh)];
	}
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView_ viewForAnnotation:(id <MKAnnotation>)annotation
{
	if(annotation == self.mapView.userLocation)
		return nil;
	else if([annotation isKindOfClass:[Region class]])
	{
		NSString* identifier = NSStringFromClass([Region class]);
		MKPinAnnotationView * pinView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(nil==pinView)
		{
			pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
			pinView.pinColor = MKPinAnnotationColorPurple;
			pinView.canShowCallout = NO;
		}
		return pinView;
	}
	else if([annotation isKindOfClass:[Station class]])
	{
		NSString* identifier = NSStringFromClass([Station class]);
		MKPinAnnotationView * pinView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(nil==pinView)
		{
			pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
			pinView.canShowCallout = YES;
			UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			[rightButton addTarget:self
							action:@selector(showDetails:)
				  forControlEvents:UIControlEventTouchUpInside];
			pinView.rightCalloutAccessoryView = rightButton;
		}
		pinView.pinColor = [(Station*)annotation isFavorite]?MKPinAnnotationColorRed:MKPinAnnotationColorGreen;
		
		return pinView;
	}
	return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	if([view.annotation isKindOfClass:[Region class]])
		[self zoomIn:(Region*)view.annotation];
    else if([view.annotation isKindOfClass:[Station class]])
        [(Station*)view.annotation refresh];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
}

/****************************************************************************/
#pragma mark Actions

- (void) setMode:(MapMode)value
{
	if(value!=self.mode)
	{
		mode = value;
        NSMutableArray * annotationsToRemove = [self.mapView.annotations mutableCopy];
        [annotationsToRemove removeObject:self.mapView.userLocation];
		[self.mapView removeAnnotations:annotationsToRemove];
		if(self.mode==MapModeRegions)
		{
			NSFetchRequest * request = [NSFetchRequest new];
			request.entity = [Region entityInManagedObjectContext:BicycletteAppDelegate.model.moc];
			[self.mapView addAnnotations:[BicycletteAppDelegate.model.moc executeFetchRequest:request error:NULL]];
		}			
	}
}

- (void) showDetails:(UIButton*)sender
{
	Station * station = (Station*)[self.mapView.selectedAnnotations objectAtIndex:0];
	
	[self.navigationController pushViewController:[StationDetailVC detailVCWithStation:station inOrderedSet:nil] animated:YES];
}

- (void) zoomIn:(Region*)region
{
	[self.mapView setRegion:[self.mapView regionThatFits:region.coordinateRegion] animated:YES];
}

- (IBAction)changeGeolocMode
{
//    switch (self.mapView.userTrackingMode) {
//        case MKUserTrackingModeNone:
//            self.mapView.userTrackingMode = MKUserTrackingModeFollow;
//            self.centerMapButton.title = @"1";
//            break;
//        case MKUserTrackingModeFollow:
//            self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
//            self.centerMapButton.title = @"2";
//            break;
//        case MKUserTrackingModeFollowWithHeading:
//            self.mapView.userTrackingMode = MKUserTrackingModeNone;
//            self.centerMapButton.title = @"0";
//            break;
//        default:
//            break;
//    }
}

/****************************************************************************/
#pragma mark -

- (void) favoriteDidChange:(NSNotification*)notif
{
	Station * station = notif.object;
	MKPinAnnotationView * pinView = (MKPinAnnotationView*)[self.mapView viewForAnnotation:station];
	pinView.pinColor = [station isFavorite]?MKPinAnnotationColorRed:MKPinAnnotationColorGreen;
}

@end
