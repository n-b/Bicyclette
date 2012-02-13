//
//  Locator.m
//  Bicyclette
//
//  Created by Nicolas on 14/11/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "Locator.h"

const struct LocatorNotifications LocatorNotifications = {
	.locationChanged = @"LocatorNotificationsLocationChanged",
};

/****************************************************************************/
#pragma mark Private Methods

@interface Locator() <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager * locationManager;
@end

/****************************************************************************/
#pragma mark Saving

@interface NSUserDefaults(BicycletteDefaults)
@property (readwrite,assign) CLLocation* lastKnownLocation;
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
		self.locationManager = [CLLocationManager new];
		self.locationManager.headingFilter = 1.0f; // degrees
		self.locationManager.delegate = self;
	}
	return self;
}

- (void) dealloc
{
	[self stop];
}

- (void) start
{
	[self.locationManager startUpdatingHeading];
	[self.locationManager startUpdatingLocation];
	[self.locationManager startMonitoringSignificantLocationChanges];
}

- (void) stop
{
	[self.locationManager stopUpdatingHeading];
	[self.locationManager stopUpdatingLocation];
	[self.locationManager stopMonitoringSignificantLocationChanges];
}

/****************************************************************************/
#pragma mark Location

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	[[NSUserDefaults standardUserDefaults] setLastKnownLocation:newLocation];
	[[NSNotificationCenter defaultCenter] postNotificationName:LocatorNotifications.locationChanged object:self];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	[[NSNotificationCenter defaultCenter] postNotificationName:LocatorNotifications.locationChanged object:self];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if([error.domain isEqualToString:kCLErrorDomain] && error.code == kCLErrorDenied)
		[self stop];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if(status == kCLAuthorizationStatusAuthorized)
		[self start];
	else
		[self stop];
}

- (CLLocation*) location
{
	return [[NSUserDefaults standardUserDefaults] lastKnownLocation];
}

@end

/****************************************************************************/
#pragma mark Saving

@implementation NSUserDefaults(BicycletteDefaults)

- (void) setLastKnownLocation:(CLLocation*) location
{
	[self setObject:[NSKeyedArchiver archivedDataWithRootObject:location] forKey:@"lastKnownLocation"];
	[self setObject:[NSDate date] forKey:@"lastKnownLocationDate"];
}

- (CLLocation*) lastKnownLocation
{
	if([[NSDate date] timeIntervalSinceDate:[self objectForKey:@"lastKnownLocationDate"]] < 15*60)
		return [NSKeyedUnarchiver unarchiveObjectWithData:[self objectForKey:@"lastKnownLocation"]];
	else
		return nil;
}

@end
