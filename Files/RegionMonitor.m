//
//  RegionMonitor.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "RegionMonitor.h"
#import "VelibModel.h"
#import "Radar.h"
#import "Station.h"
#import "NSArrayAdditions.h"
#import "NSStringAdditions.h"

@interface RegionMonitor () <NSFetchedResultsControllerDelegate, CLLocationManagerDelegate>
@property NSFetchedResultsController * frc;
@property (nonatomic, copy) NSArray * radars;
@property CLLocationManager * locationManager;
@end

@implementation RegionMonitor

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return self;
}

- (id)initWithModel:(VelibModel*)model
{
    self = [super init];
    if (self) {
        // location manager
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.purpose = NSLocalizedString(@"LOCALIZATION_PURPOSE", nil);
        [self.locationManager startUpdatingLocation];
        
        // frc
        NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:[Radar entityName]];
        request.predicate = [NSPredicate predicateWithFormat:@"%K == YES",RadarAttributes.manualRadar];
        request.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:RadarAttributes.identifier ascending:YES] ]; // frc *needs* a sort descriptor
        self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                       managedObjectContext:model.moc
                                                         sectionNameKeyPath:nil cacheName:nil];
        self.frc.delegate = self;
        [self.frc performFetch:NULL];
        
        self.radars = self.frc.fetchedObjects;

    }
    return self;
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

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"did start monitor %@",region);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        Radar * radar = [self.radars firstObjectWithValue:region.identifier forKey:RadarAttributes.identifier];

        for (Station* station in radar.stationsWithinRadarRegion) {
            UILocalNotification * userLocalNotif = [UILocalNotification new];
            NSString * shortname = station.name;
            NSRange beginRange = [shortname rangeOfString:@" - "];
            if (beginRange.location!=NSNotFound) 
                shortname = [station.name substringFromIndex:beginRange.location+beginRange.length];
            
            NSRange endRange = [shortname rangeOfString:@"("];
            if(endRange.location!=NSNotFound)
                shortname = [shortname substringToIndex:endRange.location];
            
            shortname = [shortname stringByReplacingCharactersInRange:NSMakeRange(1, shortname.length-1) withString:[[shortname substringFromIndex:1] lowercaseString]];
            
            NSString * msg = [NSString stringWithFormat:NSLocalizedString(@"STATION_%@_STATUS_SUMMARY_BIKES_%d_PARKING_%d", nil),
                              shortname,
                              station.status_availableValue, station.status_freeValue];
            userLocalNotif.alertBody = msg;
            userLocalNotif.hasAction = NO;
            userLocalNotif.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] presentLocalNotificationNow:userLocalNotif];
        }

    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"cl did fail %@",error);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"cl did fail %@ for region %@", error, region);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status==kCLAuthorizationStatusDenied || status==kCLAuthorizationStatusRestricted)
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOCALIZATION_ERROR_UNAUTHORIZED_TITLE", nil)
                                    message:NSLocalizedString(@"LOCALIZATION_ERROR_UNAUTHORIZED_MESSAGE", nil)
                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


@end
