//
//  BicycletteApplicationDelegate.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteApplicationDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "VelibDataManager.h"

/****************************************************************************/
#pragma mark Peivate Methods

@interface BicycletteApplicationDelegate() <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager * locationManager;

@end

/****************************************************************************/
#pragma mark -

@implementation BicycletteApplicationDelegate

@synthesize window;
@synthesize navigationController;
@synthesize dataManager;
@synthesize locationManager;

/****************************************************************************/
#pragma mark Application lifecycle

- (void) awakeFromNib
{
	self.dataManager = [[VelibDataManager new] autorelease];
	self.locationManager = [[CLLocationManager new] autorelease];
	self.locationManager.delegate = self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self.locationManager startUpdatingHeading];
	[self.locationManager startUpdatingLocation];
	[self.locationManager startMonitoringSignificantLocationChanges];
	
	
	[self.window addSubview:self.navigationController.view];
    [self.window makeKeyAndVisible];
	return YES;
}

- (void)dealloc {
	self.window = nil;
	self.navigationController = nil;
	self.dataManager = nil;
	self.locationManager = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark Location

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	[[NSNotificationCenter defaultCenter] postNotificationName:LocationDidChangeNotification object:manager];
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0)
{
	[[NSNotificationCenter defaultCenter] postNotificationName:LocationDidChangeNotification object:manager];
}


@end

