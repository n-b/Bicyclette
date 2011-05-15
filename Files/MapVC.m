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
#import "Locator.h"
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
@property (nonatomic) MKCoordinateRegion referenceRegion;
@property (nonatomic) MapMode mode;
- (void) showDetails:(UIButton*)sender;
- (void) zoomIn:(Region*)region;
- (void) favoriteDidChange:(NSNotification*)notif;
@end

/****************************************************************************/
#pragma mark -

@implementation MapVC 

@synthesize mapView, centerMapButton;
@synthesize referenceRegion, mode;


- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteDidChange:) 
													 name:StationFavoriteDidChangeNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

/****************************************************************************/
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.navigationItem.rightBarButtonItem = self.centerMapButton;
    
	self.referenceRegion = [self.mapView regionThatFits:BicycletteAppDelegate.model.coordinateRegion];
	self.mapView.region = self.referenceRegion;
}

- (void)viewDidUnload {
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
		
		NSFetchRequest * request = [[NSFetchRequest new] autorelease];
		[request setEntity:[Station entityInManagedObjectContext:BicycletteAppDelegate.model.moc]];
		CLLocationDegrees minLat, maxLat, minLng, maxLng;
		minLat = self.mapView.region.center.latitude - self.mapView.region.span.latitudeDelta;
		maxLat = self.mapView.region.center.latitude + self.mapView.region.span.latitudeDelta;
		minLng = self.mapView.region.center.longitude - self.mapView.region.span.longitudeDelta;
		maxLng = self.mapView.region.center.longitude + self.mapView.region.span.longitudeDelta;
		request.predicate = [NSPredicate predicateWithFormat:@"lat>%f AND lat<%f AND lng>%f AND lng<%f",
							 minLat, maxLat, minLng, maxLng];

		NSArray * oldAnnotations = self.mapView.annotations;
		NSArray * newAnnotations = [BicycletteAppDelegate.model.moc executeFetchRequest:request error:NULL];
		
		NSArray * annotationsToRemove = [oldAnnotations arrayByRemovingObjectsInArray:newAnnotations];
		NSArray * annotationsToAdd = [newAnnotations arrayByRemovingObjectsInArray:oldAnnotations];
		
		[self.mapView removeAnnotations:annotationsToRemove];
		[self.mapView addAnnotations:annotationsToAdd];
		
		NSArray * visibleFavorites = [newAnnotations filteredArrayWithSelector:@selector(isFavorite)];
		[visibleFavorites makeObjectsPerformSelector:@selector(refresh)];
	}
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	else if([annotation isKindOfClass:[Region class]])
	{
		NSString* identifier = NSStringFromClass([Region class]);
		MKPinAnnotationView * pinView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(nil==pinView)
		{
			pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
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
			pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
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

/****************************************************************************/
#pragma mark Actions

- (void) setMode:(MapMode)value
{
	if(value!=self.mode)
	{
		mode = value;
		[self.mapView removeAnnotations:self.mapView.annotations];
		if(self.mode==MapModeRegions)
		{
			NSFetchRequest * request = [[NSFetchRequest new] autorelease];
			request.entity = [Region entityInManagedObjectContext:BicycletteAppDelegate.model.moc];
			[self.mapView addAnnotations:[BicycletteAppDelegate.model.moc executeFetchRequest:request error:NULL]];
		}			
	}
}

- (void) showDetails:(UIButton*)sender
{
	Station * station = (Station*)[self.mapView.selectedAnnotations objectAtIndex:0];
	
	[self.navigationController pushViewController:[StationDetailVC detailVCWithStation:station inArray:nil] animated:YES];
}

- (void) zoomIn:(Region*)region
{
	[self.mapView setRegion:[self.mapView regionThatFits:region.coordinateRegion] animated:YES];
}

- (IBAction)changeGeolocMode
{
    if(BicycletteAppDelegate.locator.location)
        self.mapView.centerCoordinate = BicycletteAppDelegate.locator.location.coordinate;
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
