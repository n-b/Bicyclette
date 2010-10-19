//
//  BicycletteApplicationDelegate.h
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>


#define BicycletteAppDelegate ((BicycletteApplicationDelegate*)[[UIApplication sharedApplication] delegate])

@class VelibDataManager;

@interface BicycletteApplicationDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) VelibDataManager * dataManager;
@end

