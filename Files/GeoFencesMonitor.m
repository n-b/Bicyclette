//
//  GeoFencesMonitor.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "GeoFencesMonitor.h"
#import "CollectionsAdditions.h"
#import "NSStringAdditions.h"
#import "BicycletteCity.h"

@interface GeoFencesMonitor () <CLLocationManagerDelegate>
@property (nonatomic) NSMutableSet * geofences;
@property CLLocationManager * locationManager;
@property UIAlertView * authorizationAlertView;
@end

@implementation GeoFencesMonitor

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canRequestLocation)
                                                     name:BicycletteCityNotifications.canRequestLocation object:nil];

        // location manager
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        
        self.geofences = [NSMutableSet new];
    }
    return self;
}

- (void) canRequestLocation
{
    [self.locationManager startUpdatingLocation];
}

- (void) addFence:(NSObject<GeoFence>*)fence
{
    if(![self.geofences containsObject:fence])
    {
        [self monitorFence:fence];
        [fence addObserver:self forKeyPath:@"fenceRegion" options:0 context:(__bridge void *)([GeoFencesMonitor class])];
        [self.geofences addObject:fence];
    }
}

- (void) removeFence:(NSObject<GeoFence>*)fence
{
    if([self.geofences containsObject:fence])
    {
        [fence removeObserver:self forKeyPath:@"fenceRegion" context:(__bridge void *)([GeoFencesMonitor class])];
        [self.locationManager stopMonitoringForRegion:fence.fenceRegion];
    }
}

- (void) setFences:(NSSet *)geofences_
{
    for (NSObject<GeoFence>* fence in self.geofences)
        [self removeFence:fence];

    for (CLRegion * region in self.locationManager.monitoredRegions)
        [self.locationManager stopMonitoringForRegion:region];
    
    self.geofences = [geofences_ mutableCopy];
    
    for (NSObject<GeoFence>* fence in self.geofences)
        [self addFence:fence];
}

- (void) monitorFence:(NSObject<GeoFence>*)fence
{
    // the radar.fenceRegion always has the same identifier, so that the CLLocationManager knows it's the same region
    [self.locationManager startMonitoringForRegion:fence.fenceRegion];
}

/****************************************************************************/
#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([GeoFencesMonitor class])) {
        [self monitorFence:object];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/****************************************************************************/
#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"did start monitoring region %@",region);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"did enter region %@",region);
    
    NSObject<GeoFence>* fence = [self.geofences anyObjectWithValue:region.identifier forKeyPath:@"fenceRegion.identifier"];
    if(fence)
        [self.delegate monitor:self fenceWasEntered:fence];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"did exit region %@",region);
    
    NSObject<GeoFence>* fence = [self.geofences anyObjectWithValue:region.identifier forKeyPath:@"fenceRegion.identifier"];
    [self.delegate monitor:self fenceWasExited:fence];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location manager did fail: %@",error);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"monitoring for region %@ did fail: %@",region, error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self.authorizationAlertView dismissWithClickedButtonIndex:0 animated:NO];
    self.authorizationAlertView = nil;
    if(status==kCLAuthorizationStatusDenied || status==kCLAuthorizationStatusRestricted)
    {
        NSString * message = NSLocalizedStringFromTable(@"NSLocationUsageDescription", @"InfoPlist", nil);
        if (status==kCLAuthorizationStatusDenied) {
            message = [message stringByAppendingFormat:@"\n%@",NSLocalizedString(@"LOCALIZATION_ERROR_UNAUTHORIZED_DENIED_MESSAGE", nil)];
        }
        self.authorizationAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOCALIZATION_ERROR_UNAUTHORIZED_TITLE", nil)
                                                                 message:message
                                                                delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.authorizationAlertView show];
    }
}


@end
