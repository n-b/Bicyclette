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

@class VelibDataManager, Locator;

@interface BicycletteApplicationDelegate : NSObject <UIApplicationDelegate> 

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIView *notificationView;

@property (nonatomic, retain, readonly) VelibDataManager * dataManager;
@property (nonatomic, retain, readonly) Locator * locator;

- (IBAction) selectTab:(UIBarButtonItem*)sender;
@end

