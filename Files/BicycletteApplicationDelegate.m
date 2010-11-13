//
//  BicycletteApplicationDelegate.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteApplicationDelegate.h"
#import "VelibDataManager.h"

@implementation BicycletteApplicationDelegate

@synthesize window;
@synthesize navigationController;
@synthesize dataManager;

#pragma mark -
#pragma mark Application lifecycle

- (void) awakeFromNib
{
	self.dataManager = [[[VelibDataManager alloc] init] autorelease];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

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

