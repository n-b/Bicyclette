//
//  MapVC+DebugScreenshots.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/09/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#if SCREENSHOTS

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

#import "MapVC+DebugScreenshots.h"
#import "UIApplication+screenshot.h"
#import "BicycletteCity.h"
#import "CollectionsAdditions.h"
#import "UIApplication+LocalAlerts.h"

@interface MapVC(Protected)
@property MKMapView * mapView;
@property UISegmentedControl * modeControl;
@end

@implementation MapVC (DebugScreenshots)

static BOOL gShouldShowAnnotations = NO;

// Override methods from MapVC.m
- (void) controller:(CitiesController*)controller setAnnotations:(NSArray*)newAnnotations overlays:(NSArray*)newOverlays
{
    NSArray * oldAnnotations = [self.mapView.annotations arrayByRemovingObjectsInArray:@[ self.mapView.userLocation ]];
    [self.mapView removeAnnotations:[oldAnnotations arrayByRemovingObjectsInArray:newAnnotations]];

    if(gShouldShowAnnotations)
        [self.mapView addAnnotations:[newAnnotations arrayByRemovingObjectsInArray:oldAnnotations]];
    
    NSArray * oldOverlays = self.mapView.overlays;
    [self.mapView removeOverlays:[oldOverlays arrayByRemovingObjectsInArray:newOverlays]];
    if(gShouldShowAnnotations)
        [self.mapView addOverlays:[newOverlays arrayByRemovingObjectsInArray:oldOverlays]];
}

/****************************************************************************/
#pragma mark -

- (void) saveScreenshotWithNameTemplate:(NSString*)name localized:(BOOL)localized
{
    NSDictionary * suffixes = @{@480 : @"",
                                @640 : @"-Landscape-iPhone",
                                @960 : @"@2x",
                                @1280 : @"-Landscape-iPhone@2x",
                                @1136 : @"-568h@2x",
                                @768 : @"-Landscape",
                                @1536 : @"-Landscape@2x",
                                @1024 : @"-Portrait",
                                @2048 : @"-Portrait@2x",
                                };
    CGFloat height = self.view.frame.size.height * [[UIScreen mainScreen] scale];
    NSString * suffix = suffixes[@(height)];
    NSAssert(suffix, @"invalid screenshot height : %f",height);
    [self saveScreenshotNamed:[NSString stringWithFormat:@"%@%@",name,suffix] localized:localized];
}

- (NSString*) screenshotsPathLocalized:(BOOL)localized
{
    NSString * path = [NSUserDefaults.standardUserDefaults stringForKey:@"DebugScreenshotPath"];
    path = [path stringByExpandingTildeInPath];
    if(localized)
        path = [path stringByAppendingPathComponent:[NSLocale preferredLanguages][0]];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    return path;
}

- (void) saveScreenshotNamed:(NSString*)name localized:(BOOL)localized
{
    UIImage * screenshot = [[UIApplication sharedApplication] screenshot];
    NSString * savePath = [[[self screenshotsPathLocalized:localized] stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"png"];
    NSLog(@"Saving screenshot %@",savePath);
    [UIImagePNGRepresentation(screenshot) writeToFile:savePath atomically:NO];
}

/****************************************************************************/
#pragma mark -

- (void) takeScreenshots
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"TakeDefaultScreenshot"])
    {
        [self takeScreenshotForDefault];
    }
    else if([[NSUserDefaults standardUserDefaults] boolForKey:@"TakeUIScreenshots"])
    {
        gShouldShowAnnotations = YES;
        [self takeScreenshotForNYC];
    }
}

/****************************************************************************/
#pragma mark -

- (void) takeScreenshotForDefault
{
    self.modeControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    [self.modeControl setTitle:@"" forSegmentAtIndex:0];
    [self.modeControl setTitle:@"" forSegmentAtIndex:1];
    [self saveScreenshotWithNameTemplate:@"Default" localized:NO];
    exit(0);
}

- (void) takeScreenshotForWorld
{
    MKCoordinateRegion europe = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(45, -10),
                                                                   8000000, 8000000);
    [self.mapView setRegion:europe animated:NO];
    [self performSelector:@selector(takeScreenshotForWorld_2) withObject:nil afterDelay:6];
}

- (void) takeScreenshotForWorld_2
{
    [self saveScreenshotWithNameTemplate:@"World" localized:YES];
    
    [self performSelector:@selector(takeScreenshotForEurope) withObject:nil afterDelay:1];
}

- (void) takeScreenshotForEurope
{
    MKCoordinateRegion europe = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(46.892686, 3.520008),
                                                       2000000, 2000000);
    [self.mapView setRegion:europe animated:NO];
    [self performSelector:@selector(takeScreenshotForEurope_2) withObject:nil afterDelay:4];
}

- (void) takeScreenshotForEurope_2
{
    [self saveScreenshotWithNameTemplate:@"Europe" localized:YES];

    [self performSelector:@selector(takeScreenshotForNotreDame) withObject:nil afterDelay:1];
}

- (CLLocationDistance) distanceForNotreDame
{
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad)
        return 2000.;
    else
        return 1000.;
}

- (void) takeScreenshotForNotreDame
{
    MKCoordinateRegion cite = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(48.857015, 2.348206),
                                                       self.distanceForNotreDame,self.distanceForNotreDame);
    [self.mapView setRegion:cite animated:NO];
    [self.controller selectStationNumber:@"4001" inCityNamed:@"Paris" changeRegion:NO];
    Station * notredame = [[self.controller cityNamed:@"Paris"] stationWithNumber:@"4001"];
    if(! notredame.starredValue)
        [self.controller switchStarredStation:notredame];
    [self performSelector:@selector(takeScreenshotForNotreDame_2) withObject:nil afterDelay:5];
}

- (void) takeScreenshotForNotreDame_2
{
    [self saveScreenshotWithNameTemplate:@"NotreDame" localized:YES];
    [self performSelector:@selector(takeScreenshotForLincolnMemorial) withObject:nil afterDelay:1];
}

- (CLLocationDistance) distanceForLincolnMemorial
{
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad)
        return 4000.;
    else
        return 3000.;
}

- (void) takeScreenshotForLincolnMemorial
{
    MKCoordinateRegion washington = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(38.880661, -77.033085),
                                                           self.distanceForLincolnMemorial,self.distanceForLincolnMemorial);
    [self.mapView setRegion:washington animated:NO];
    [self.controller selectStationNumber:@"204" inCityNamed:@"Washington" changeRegion:NO];
    [self performSelector:@selector(takeScreenshotForLincolnMemorial_2) withObject:nil afterDelay:4];
}

- (void) takeScreenshotForLincolnMemorial_2
{
    [self saveScreenshotWithNameTemplate:@"LincolnMemorial" localized:YES];
    [self performSelector:@selector(takeScreenshotForNYC) withObject:nil afterDelay:1];
}

- (CLLocationDistance) distanceForNYC
{
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad)
        return 4000.;
    else
        return 3000.;
}

- (void) takeScreenshotForNYC
{
    MKCoordinateRegion washington = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(40.71076228, -73.99400398),
                                                                       self.distanceForNYC,self.distanceForNYC);
    [self.mapView setRegion:washington animated:NO];
    [self.controller selectStationNumber:@"408" inCityNamed:@"New York City" changeRegion:NO];
    [self performSelector:@selector(takeScreenshotForNYC_2) withObject:nil afterDelay:8];
}

- (void) takeScreenshotForNYC_2
{
    [self saveScreenshotWithNameTemplate:@"NYC" localized:YES];
    [self performSelector:@selector(takeLockedScreenshot) withObject:nil afterDelay:1];
}


- (void) takeLockedScreenshot
{
    UILocalNotification * ndNotif = [UILocalNotification new];
    ndNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"STATION_%@_STATUS_SUMMARY_BIKES_%d_PARKING_%d", nil),
                                @"Notre Dame",
                                10, 0];
    ndNotif.hasAction = NO;
    ndNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:.7];
    [[UIApplication sharedApplication] scheduleLocalNotification:ndNotif];

    UILocalNotification * mfNotif = [UILocalNotification new];
    mfNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"STATION_%@_STATUS_SUMMARY_BIKES_%d_PARKING_%d", nil),
                                @"Marché aux Fleurs",
                                4, 8];
    mfNotif.hasAction = NO;
    mfNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:.6];
    [[UIApplication sharedApplication] scheduleLocalNotification:mfNotif];

    // Lock. I'm basically dead now.
    system("osascript -e \"tell application id \\\"com.apple.iphonesimulator\\\" to activate\" -e \"tell application \\\"System Events\\\" to keystroke \\\"l\\\" using command down\"");
    
    exit(0);
}
@end

#pragma clang diagnostic pop

#endif
