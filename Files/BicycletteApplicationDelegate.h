//
//  BicycletteApplicationDelegate.h
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>


#define BicycletteAppDelegate ((BicycletteApplicationDelegate*)[[UIApplication sharedApplication] delegate])

@class VelibDataManager, Locator;

@interface BicycletteApplicationDelegate : NSObject <UIApplicationDelegate> 

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain, readonly) VelibDataManager * dataManager;
@property (nonatomic, retain, readonly) Locator * locator;

@end

