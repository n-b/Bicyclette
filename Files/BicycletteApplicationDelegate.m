//
//  BicycletteApplicationDelegate.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteApplicationDelegate.h"
#import "Station.h"
#import "RootVC.h"
#import "CitiesController.h"
#import "BicycletteCity.h"

/****************************************************************************/
#pragma mark Private Methods

@interface BicycletteApplicationDelegate()
@property CitiesController * citiesController;

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

    // Google Analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
#if DEBUG
    [GAI sharedInstance].debug = YES;
#endif
    NSString * trackingID = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"_GoogleAnalytics" ofType:@"plist"]] objectForKey:@"TrackingID"];
    [[GAI sharedInstance] trackerWithTrackingId:trackingID];
    [GAI sharedInstance].defaultTracker.useHttps = NO;
    [GAI sharedInstance].defaultTracker.anonymize = YES;
    
    self.citiesController = [CitiesController new];
    
    self.rootVC.citiesController = self.citiesController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Clear all notifications.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // Must not do it automatically, otherwise the UI is broken vertically, initially, on iPad on iOS 5
    self.window.rootViewController = self.rootVC;
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[GAI sharedInstance] dispatch];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Clear all notifications.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if([notification.userInfo[@"type"] isEqualToString:@"stationsummary"])
        [self.citiesController handleLocalNotificaion:notification];
}

@end
