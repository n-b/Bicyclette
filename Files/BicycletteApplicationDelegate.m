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
#pragma mark Private Methods

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
	// Load Factory Defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"FactoryDefaults" ofType:@"plist"]]];
	
	self.dataManager = [[VelibDataManager new] autorelease];
	self.locator = [[Locator new] autorelease];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self.locator start];
	[self.window addSubview:self.navigationController.view];
	[self.window makeKeyAndVisible];
	
	UIView * fadeView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]] autorelease];
	[self.window addSubview:fadeView];
	[UIView beginAnimations:nil context:NULL];
	fadeView.alpha = 0;
	fadeView.transform = CGAffineTransformMakeScale(2, 2);
	[fadeView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1];
	[UIView commitAnimations];
	
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
