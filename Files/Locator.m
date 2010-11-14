//
//  Locator.m
//  Bicyclette
//
//  Created by Nicolas on 14/11/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "Locator.h"

/****************************************************************************/
#pragma mark Private Methods

@interface Locator() <CLLocationManagerDelegate>
@property (nonatomic, retain) CLLocationManager * locationManager;
@end

/****************************************************************************/
#pragma mark -

@implementation Locator
@synthesize locationManager;

/****************************************************************************/
#pragma mark Life Cycle

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.locationManager = [[CLLocationManager new] autorelease];
		self.locationManager.delegate = self;
	}
	return self;
}

- (void) start
{
	[self.locationManager startUpdatingHeading];
	[self.locationManager startUpdatingLocation];
	[self.locationManager startMonitoringSignificantLocationChanges];
}

- (void) dealloc
{
	self.locationManager = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark Location

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	[[NSNotificationCenter defaultCenter] postNotificationName:LocationDidChangeNotification object:self];
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0)
{
	[[NSNotificationCenter defaultCenter] postNotificationName:LocationDidChangeNotification object:self];
}

@end
