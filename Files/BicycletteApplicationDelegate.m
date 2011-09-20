//
//  BicycletteApplicationDelegate.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteApplicationDelegate.h"
#import "VelibModel.h"
#import "Locator.h"
#import "BicycletteBar.h"
#include <unistd.h>
#import "DataUpdater.h"

/****************************************************************************/
#pragma mark Private Methods

@interface BicycletteApplicationDelegate() <BicycletteBarDelegate, CoreDataManagerDelegate>

@property (nonatomic, retain) VelibModel * model;
@property (nonatomic, retain) Locator * locator;

- (void) selectTabIndex:(NSUInteger)index;

@end

/****************************************************************************/
#pragma mark -

@implementation BicycletteApplicationDelegate

@synthesize window, tabBarController, toolbar, notificationView;
@synthesize model;
@synthesize locator;

/****************************************************************************/
#pragma mark Application lifecycle

- (void) awakeFromNib
{
	// Load Factory Defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"FactoryDefaults" ofType:@"plist"]]];

    // Create model
    self.model = [[VelibModel new] autorelease];
    self.model.delegate = self;
	self.locator = [[Locator new] autorelease];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self.window insertSubview:self.tabBarController.view belowSubview:self.toolbar];
	
	// Hide the tabbar, the toolbar's segmented control is used instead
	self.tabBarController.tabBar.hidden = YES;
	UIView * contentView = [self.tabBarController.view.subviews objectAtIndex:0];
	contentView.frame = [[UIScreen mainScreen] bounds];
	
	[self selectTabIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedTabIndex"]];
	
	// notification view
	self.notificationView.layer.cornerRadius = 10;
	[self.window addSubview:self.notificationView];
	self.notificationView.center = self.window.center;
    [self.model addObserver:self forKeyPath:@"updater.downloadingUpdate" options:NSKeyValueObservingOptionInitial context:[BicycletteApplicationDelegate class]];

	[self.window makeKeyAndVisible];

    // Fade animation
	UIView * fadeView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]] autorelease];
	[self.window addSubview:fadeView];
	[UIView beginAnimations:nil context:NULL];
	fadeView.alpha = 0;
	fadeView.transform = CGAffineTransformMakeScale(2, 2);
	[fadeView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1];
	[UIView commitAnimations];

	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[self.locator start];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[self.locator stop];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)self.tabBarController.selectedIndex forKey:@"SelectedTabIndex"];
	[self.locator stop];
    usleep(500*1000);
}

- (void)dealloc {
	self.window = nil;
	self.tabBarController = nil;
	self.toolbar = nil;
	self.notificationView = nil;
	[self.model removeObserver:self forKeyPath:@"updater.downloadingUpdate"];
	self.model = nil;
	self.locator = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark Tab Selection

- (void) bicycletteBar:(BicycletteBar*)bar didSelectIndex:(NSUInteger)index
{
	BOOL shouldPop = self.tabBarController.selectedIndex==index;
	[self selectTabIndex:index];
	if(shouldPop)
		[(UINavigationController*)self.tabBarController.selectedViewController popToRootViewControllerAnimated:YES];
}

- (void) selectTabIndex:(NSUInteger)index
{
	self.tabBarController.selectedIndex = index;
	self.toolbar.selectedIndex = index;
}

/****************************************************************************/
#pragma mark CoreDataManager delegate

- (void) coreDataManager:(CoreDataManager*)manager didSave:(BOOL)success withErrors:(NSArray*)errors
{
    if(errors)
    {
        NSString * title = success ? NSLocalizedString(@"Some invalid data could not be saved.", 0) : NSLocalizedString(@"Invalid data prevented data to be saved.", 0);
        NSMutableString * message = [NSMutableString string];
        for (NSError * error in errors) {
            [message appendFormat:@"%@ : %@\n",error.localizedDescription,error.localizedFailureReason];
        }
        UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", 0) otherButtonTitles:nil] autorelease];
        [alert show];
    }
}

/****************************************************************************/
#pragma mark -

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == [BicycletteApplicationDelegate class]) {
		[UIView beginAnimations:nil context:NULL];
		self.notificationView.alpha = self.model.updater.downloadingUpdate?1.f:0.f;
		[UIView commitAnimations];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end
