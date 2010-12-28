//
//  MapVC.m
//  Bicyclette
//
//  Created by Nicolas on 04/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "MapVC.h"
#import "BicycletteApplicationDelegate.h"
#import "VelibDataManager.h"
#import "Station.h"
#import "Region.h"

typedef enum {
	MapModeNone = 0,
	MapModeRegions,
	MapModeStations
}  MapMode;

@interface MapVC() <MKMapViewDelegate>
@property (nonatomic) MKCoordinateRegion referenceRegion;
@property (nonatomic) MapMode mode;
@end

/****************************************************************************/
#pragma mark -

@implementation MapVC 

@synthesize mapView;
@synthesize referenceRegion, mode;

- (void)dealloc {
    [super dealloc];
}

/****************************************************************************/
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.referenceRegion = [self.mapView regionThatFits:BicycletteAppDelegate.dataManager.coordinateRegion];
	self.mapView.region = self.referenceRegion;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

/****************************************************************************/
#pragma mark -

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	CLLocationDegrees modelSpan = self.referenceRegion.span.latitudeDelta;
	if(self.mapView.region.span.latitudeDelta>modelSpan*2.0f)
		self.mode = MapModeNone;
	else if(self.mapView.region.span.latitudeDelta>modelSpan/16.0f)
		self.mode = MapModeRegions;
	else
		self.mode = MapModeStations;
}

- (void) setMode:(MapMode)value
{
	if(value!=self.mode)
	{
		mode = value;
		[self.mapView removeAnnotations:self.mapView.annotations];
		if(self.mode==MapModeNone)
			return;
		NSFetchRequest * request = [[NSFetchRequest new] autorelease];
		Class class = self.mode==MapModeRegions?[Region class]:[Station class];
		[request setEntity:[class entityInManagedObjectContext:BicycletteAppDelegate.dataManager.moc]];
		[self.mapView addAnnotations:[BicycletteAppDelegate.dataManager.moc executeFetchRequest:request error:NULL]];
	}
}

@end
