//
//  BicycletteApplicationDelegate.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteApplicationDelegate.h"
#import "VelibDataManager.h"
#import "Locator.h"

/****************************************************************************/
#pragma mark Peivate Methods

@interface BicycletteApplicationDelegate()

@property (nonatomic, retain) VelibDataManager * dataManager;
@property (nonatomic, retain) Locator * locator;

@end

/****************************************************************************/
#pragma mark -

@implementation BicycletteApplicationDelegate

@synthesize window;
@synthesize navigationController;
@synthesize dataManager;
@synthesize locator;

/****************************************************************************/
#pragma mark Application lifecycle

- (void) awakeFromNib
{
	self.dataManager = [[VelibDataManager new] autorelease];
	self.locator = [[Locator new] autorelease];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self.locator start];
	[self.window addSubview:self.navigationController.view];
    [self.window makeKeyAndVisible];
	return YES;
}

- (void)dealloc {
	self.window = nil;
	self.navigationController = nil;
	self.dataManager = nil;
	self.locator = nil;
	[super dealloc];
}

@end

