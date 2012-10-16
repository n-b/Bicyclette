//
//  RegionMonitor.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "RegionMonitor.h"
#import "BicycletteCity.h"
#import "Radar.h"
#import "Station.h"
#import "NSArrayAdditions.h"
#import "NSStringAdditions.h"
#import "UIApplication+LocalAlerts.h"

@interface RegionMonitor () <NSFetchedResultsControllerDelegate, CLLocationManagerDelegate>
@property NSFetchedResultsController * frc;
@property (nonatomic, copy) NSArray * radars;
@property CLLocationManager * locationManager;
@property UIAlertView * authorizationAlertView;
@end

@implementation RegionMonitor

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return self;
}

- (id)initWithCity:(BicycletteCity*)city_
{
    self = [super init];
    if (self) {
        // location manager
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.purpose = NSLocalizedString(@"LOCALIZATION_PURPOSE", nil);
        
        // frc
        NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:[Radar entityName]];
        request.predicate = [NSPredicate predicateWithFormat:@"%K == YES",RadarAttributes.manualRadar];
        request.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:RadarAttributes.identifier ascending:YES] ]; // frc *needs* a sort descriptor
        self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                       managedObjectContext:city_.moc
                                                         sectionNameKeyPath:nil cacheName:nil];
        self.frc.delegate = self;
        [self.frc performFetch:NULL];
        
        self.radars = self.frc.fetchedObjects;

    }
    return self;
}

- (void) startUsingUserLocation
{
    [self.locationManager startUpdatingLocation];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.radars = controller.fetchedObjects;
}

- (void) setRadars:(NSArray *)radars_
{
    for (Radar * radar in _radars)
        [radar removeObserver:self forKeyPath:@"coordinate" context:(__bridge void *)([RegionMonitor class])];
    for (CLRegion * region in self.locationManager.monitoredRegions)
        [self.locationManager stopMonitoringForRegion:region];
    
    _radars = [radars_ copy];
    
    for (Radar * radar in _radars)
    {
        [self monitorRadar:radar];
        [radar addObserver:self forKeyPath:@"coordinate" options:0 context:(__bridge void *)([RegionMonitor class])];
    }
}

- (void) monitorRadar:(Radar*)radar
{
    // the radar.monitoringRegion always has the same identifier, so that the CLLocationManager knows it's the same region
    [self.locationManager startMonitoringForRegion:radar.monitoringRegion];
}

/****************************************************************************/
#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([RegionMonitor class])) {
        [self monitorRadar:object];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/****************************************************************************/
#pragma mark -

- (void)logDebug:(NSString*)format, ...
{
    va_list args; va_start(args, format);
    NSString * message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"DebugLogRegionMonitoring"])
        NSLog(@"%@",message);
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"DebugLogRegionMonitoringWithLocalNotifications"])
        [[UIApplication sharedApplication] presentLocalNotificationMessage:message];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self logDebug:@"did start monitoring %@",region];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self logDebug:@"did enter region %@",region];
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        Radar * radar = [self.radars firstObjectWithValue:region.identifier forKey:RadarAttributes.identifier];
        [radar setWantsSummary];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    Radar * radar = [self.radars firstObjectWithValue:region.identifier forKey:RadarAttributes.identifier];
    [self logDebug:@"did exit region %@",region];
    [radar clearWantsSummary];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self logDebug:@"location manager did fail: %@",error];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self logDebug:@"monitoring for region %@ did fail: %@",region, error];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self.authorizationAlertView dismissWithClickedButtonIndex:0 animated:NO];
    self.authorizationAlertView = nil;
    if(status==kCLAuthorizationStatusDenied || status==kCLAuthorizationStatusRestricted)
    {
        NSString * message = NSLocalizedString(@"LOCALIZATION_PURPOSE", nil);
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
