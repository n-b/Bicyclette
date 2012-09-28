//
//  MapVC+DebugScreenshots.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/09/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "MapVC+DebugScreenshots.h"
#import "UIApplication+screenshot.h"
#import "Radar.h"
#import "VelibModel.h"

@interface MapVC(Protected)
@property MKMapView * mapView;
- (void) createRadarAtPoint:(CGPoint)pointInMapView;
@end

@implementation MapVC (DebugScreenshots)

- (void) saveScreenshotNamed:(NSString*)name
{
    UIImage * screenshot = [[UIApplication sharedApplication] screenshot];
    NSString * path = [NSUserDefaults.standardUserDefaults stringForKey:@"DebugScreenshotPath"];
    path = [[path stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"png"];
    NSLog(@"Saving screenshot to %@",path);
    [UIImagePNGRepresentation(screenshot) writeToFile:path atomically:NO];
}

- (void) takeScreenshotForDefaultAndExit
{
    CGFloat height = self.view.frame.size.height * [[UIScreen mainScreen] scale];
    NSDictionary * names = (@{@460 : @"Default",
                            @920 : @"Default@2x",
                            @1096 : @"Default-568h@2x",
                            @748 : @"Default-Landscape",
                            @1496 : @"Default-Landscape@2x",
                            @1004 : @"Default-Portrait",
                            @2008 : @"Default-Portrait@2x",
                            });
    
    [self saveScreenshotNamed:names[@(height)]];
    
    exit(0);
}

- (void) takeScreenshotsForITCAndExit
{
    // zoom in user
    BOOL isIpad = [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad;
    CGFloat meters = isIpad?800:300;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, meters, meters);
    [self.mapView setRegion:region animated:NO];
    
    // delete any remaining radar
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:[Radar entityName]];
    request.predicate = [NSPredicate predicateWithFormat:@"%K == YES",RadarAttributes.manualRadar];
    NSArray * radars = [self.model.moc executeFetchRequest:request error:NULL];
    for (Radar * radar in radars) {
        [self.mapView removeAnnotation:radar];
        [self.model.moc deleteObject:radar];
    }

    // wait for the map to load
    [self performSelector:@selector(_takeScreenshotsForITCAndExit_step2) withObject:nil afterDelay:4.5];
}

- (void) _takeScreenshotsForITCAndExit_step2
{
    // take a first screenshot
    BOOL isIpad = [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad;
    NSString * name = isIpad?@"saintmichel~ipad":@"saintmichel";
    [self saveScreenshotNamed:name];
    
    // create a radar
    CGPoint radarPoint = self.mapView.center;
    radarPoint.x -= 35;
    radarPoint.y += 66;
    [self createRadarAtPoint:radarPoint];
    
    // wait for the animation
    [self performSelector:@selector(_takeScreenshotsForITCAndExit_step3) withObject:nil afterDelay:1];
}

- (void) _takeScreenshotsForITCAndExit_step3
{
    BOOL isIpad = [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad;
    NSString * name = isIpad?@"radar2~ipad":@"radar2";
    [self saveScreenshotNamed:name];
    
    exit(0);
}


@end
