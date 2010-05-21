//
//  BicycletteAppDelegate.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "BicycletteAppDelegate.h"
#import "RootViewController.h"


@implementation BicycletteAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

