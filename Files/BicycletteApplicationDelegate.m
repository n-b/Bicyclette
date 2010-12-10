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
#import "BicycletteBar.h"

/****************************************************************************/
#pragma mark Private Methods

@interface BicycletteApplicationDelegate() <BicycletteBarDelegate>

@property (nonatomic, retain) VelibDataManager * dataManager;
@property (nonatomic, retain) Locator * locator;

- (void) selectTabIndex:(NSUInteger)index;

@end

/****************************************************************************/
#pragma mark -

@implementation BicycletteApplicationDelegate

@synthesize window, tabBarController, toolbar, notificationView;
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
	[self.dataManager addObserver:self forKeyPath:@"downloadingUpdate" options:0 context:[BicycletteApplicationDelegate class]];
	self.locator = [[Locator new] autorelease];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self.locator start];
	[self.window insertSubview:self.tabBarController.view belowSubview:self.toolbar];
	
	// Hide the tabbar, the toolbar's segmented control is used instead
	self.tabBarController.tabBar.hidden = YES;
	UIView * contentView = [self.tabBarController.view.subviews objectAtIndex:0];
	contentView.frame = [[UIScreen mainScreen] bounds];
	
	[self selectTabIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedTabIndex"]];
	
	// notification view
	self.notificationView.alpha = 0.f;
	self.notificationView.layer.cornerRadius = 10;
	[self.window addSubview:self.notificationView];
	self.notificationView.center = self.window.center;
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

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)self.tabBarController.selectedIndex forKey:@"SelectedTabIndex"];
}

- (void)dealloc {
	self.window = nil;
	self.tabBarController = nil;
	self.toolbar = nil;
	self.notificationView = nil;
	[self.dataManager removeObserver:self forKeyPath:@"downloadingUpdate"];
	self.dataManager = nil;
	self.locator = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark Tab Selection

- (void) bicycletteBar:(BicycletteBar*)bar didSelectIndex:(NSUInteger)index
{
	[self selectTabIndex:index];
}

- (void) selectTabIndex:(NSUInteger)index
{
	self.tabBarController.selectedIndex = index;
	self.toolbar.selectedIndex = index;
}

/****************************************************************************/
#pragma mark -

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == [BicycletteApplicationDelegate class]) {
		[UIView beginAnimations:nil context:NULL];
		self.notificationView.alpha = self.dataManager.downloadingUpdate?1.f:0.f;
		[UIView commitAnimations];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end
