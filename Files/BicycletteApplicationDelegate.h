//
//  BicycletteApplicationDelegate.h
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BicycletteBlue			[UIColor colorWithHue:.61f saturation:.87f brightness:.8f alpha:1]
#define BicycletteAppDelegate ((BicycletteApplicationDelegate*)[[UIApplication sharedApplication] delegate])

@class VelibModel, Locator, BicycletteBar;

@interface BicycletteApplicationDelegate : NSObject <UIApplicationDelegate> 

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, strong) IBOutlet BicycletteBar *toolbar;
@property (nonatomic, strong) IBOutlet UIView *notificationView;

@property (nonatomic, strong, readonly) VelibModel * model;
@property (nonatomic, strong, readonly) Locator * locator;

@end

