//
//  BicycletteApplicationDelegate.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteApplicationDelegate.h"
#import "ParisVelibCity.h"
#import "MarseilleLeveloCity.h"
#import "ToulouseVeloCity.h"
#import "AmiensVelamCity.h"
#import "Station.h"
#import "RootVC.h"

/****************************************************************************/
#pragma mark Private Methods

@interface BicycletteApplicationDelegate()
@property NSArray * cities;

@property IBOutlet RootVC *rootVC;
@end

/****************************************************************************/
#pragma mark -

@implementation BicycletteApplicationDelegate

/****************************************************************************/
#pragma mark Application lifecycle

- (void) awakeFromNib
{
	// Load Factory Defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"FactoryDefaults" ofType:@"plist"]]];
    
    // Create city
    [self.rootVC setCities:(@[[ParisVelibCity new],
                              [MarseilleLeveloCity new],
                              [ToulouseVeloCity new],
                              [AmiensVelamCity new] ])];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Must not do it automatically, otherwise the UI is broken vertically, initially, on iPad on iOS 5
    self.window.rootViewController = self.rootVC;
	return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSString * cityClassName = notification.userInfo[@"city"];
    BicycletteCity * city;
    for (BicycletteCity * aCity in self.cities) {
        if([NSStringFromClass([aCity class]) isEqualToString:cityClassName])
        {
            city = aCity;
            break;
        }
    }
    NSString * number = notification.userInfo[@"stationNumber"];
    if(number)
    {
        Station * station = [city stationWithNumber:number];
        [self.rootVC zoomInStation:station];
    }
}

@end
