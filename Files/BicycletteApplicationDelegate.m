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
    
    self.citiesController = [CitiesController new];
    
    self.rootVC.citiesController = self.citiesController;
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
