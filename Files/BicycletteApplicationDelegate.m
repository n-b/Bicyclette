//
//  BicycletteApplicationDelegate.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteApplicationDelegate.h"
#import "VelibModel.h"
#import "DataUpdater.h"
#import "MapVC.h"
#import "PrefsVC.h"
#import "HelpVC.h"
#import "UIView+Screenshot.h"
#import "RegionMonitor.h"
#import "Station.h"

/****************************************************************************/
#pragma mark Private Methods

@interface BicycletteApplicationDelegate()
@property (strong) VelibModel * model;
@property (strong) RegionMonitor * regionMonitor;

@property (strong) IBOutlet UINavigationController *rootNavC;
@property (strong) IBOutlet MapVC *mapVC;
@property (strong) IBOutlet PrefsVC *prefsVC;
@property (strong) IBOutlet HelpVC *helpVC;

@property (strong) UIImageView *screenshot;
@property (strong) IBOutlet UIToolbar *infoToolbar;
@property (strong) IBOutlet UIButton *infoButton;
@end

/****************************************************************************/
#pragma mark -

@implementation BicycletteApplicationDelegate

/****************************************************************************/
#pragma mark Application lifecycle

- (void) awakeFromNib
{
	// Load Factory Defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"FactoryDefaults" ofType:@"plist"]]];
    
    // Create model
    self.model = [VelibModel new];
    self.mapVC.model = self.model;
    self.prefsVC.model = self.model;
    self.regionMonitor = [[RegionMonitor alloc] initWithModel:self.model];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// info button
    CGRect rootViewFrame = self.rootNavC.view.bounds;
    [self.rootNavC.view addSubview:self.infoToolbar];
    CGRect infoToolbarFrame = self.infoToolbar.frame;
    infoToolbarFrame.origin.x = rootViewFrame.size.width - infoToolbarFrame.size.width;
    infoToolbarFrame.origin.y = rootViewFrame.size.height - infoToolbarFrame.size.height;
    self.infoToolbar.frame = infoToolbarFrame;
    self.infoButton.center = self.infoToolbar.center;
    CGRect f = self.infoButton.frame;
    f.origin.y = lroundf(f.origin.y);
    self.infoButton.frame = f;
    [self.rootNavC.view addSubview:self.infoButton];

    // Show help at first launch
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"DisplayHelpAtLaunch"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"DebugDisplayHelpAtLaunch"])
    {
        [self.rootNavC.view addSubview:self.helpVC.view];
        [self.helpVC viewWillAppear:NO];
        self.helpVC.view.frame = self.rootNavC.view.bounds;
        [self.helpVC viewDidAppear:NO];
    }
    else
    {
        [self finishStart];
    }
    
	return YES;
}

- (IBAction)closeHelp:(id)sender
{
    [UIView animateWithDuration:.5 animations:^{
        self.helpVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.helpVC.view removeFromSuperview];
        self.helpVC = nil;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DisplayHelpAtLaunch"];
        [self finishStart];
    }];
}

- (void) finishStart
{
    [self.regionMonitor startUsingUserLocation];
    [self.mapVC startUsingUserLocation];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    Station * station = [self.model stationWithNumber:notification.userInfo[@"stationNumber"]];
    [self.mapVC zoomInStation:station];
}

/****************************************************************************/
#pragma mark Prefs / Map Transition

- (IBAction)showInfo
{
    if(self.rootNavC.visibleViewController==self.mapVC)
    {
        UIView * rootView = self.rootNavC.view;
        // Hide MapVC, Show PrefsVC.
        [self.mapVC setAnnotationsHidden:YES];
        
        // Rotate around infoButton
        CGPoint rotationCenter = self.infoButton.center;
        
        // Take a screenshot of the mapVC view
        UIView * mapView = self.mapVC.view;
        self.screenshot = [[UIImageView alloc] initWithImage:[mapView screenshot]];

        // Present (not animated)
        [self.rootNavC pushViewController:self.prefsVC animated:NO];

        // Add the screenshot
        [rootView insertSubview:self.screenshot belowSubview:self.infoToolbar];
        
        // Align the screenshot around the rotation center
        self.screenshot.layer.anchorPoint = CGPointMake(rotationCenter.x/rootView.bounds.size.width,
                                                        rotationCenter.y/rootView.bounds.size.height);
        CGSize translation = CGSizeMake(rotationCenter.x-CGRectGetMidX(mapView.bounds),
                                        rotationCenter.y-CGRectGetMidY(mapView.bounds));
        self.screenshot.transform = CGAffineTransformMakeTranslation(translation.width, translation.height);

        // Poor man's shadow for the screenshot (faster during animation)
        self.screenshot.userInteractionEnabled = YES;
        self.screenshot.layer.borderWidth = 1;
        self.screenshot.layer.borderColor = [UIColor darkGrayColor].CGColor;

        // Animate
        [UIView animateWithDuration:.5
                         animations:^(void) {
                             CGAffineTransform rotation = CGAffineTransformMakeRotation(.9*M_PI);
                             self.screenshot.transform = CGAffineTransformConcat(rotation, self.screenshot.transform);
                         } completion:^(BOOL finished) {
                             // Real Shadow when static
                             self.screenshot.layer.borderWidth = 0;
                             self.screenshot.layer.shadowOffset = CGSizeZero;
                             self.screenshot.layer.shadowRadius = 2;
                             self.screenshot.layer.shadowOpacity = 1;
                             self.screenshot.layer.shadowColor = [UIColor blackColor].CGColor;
                         }];
    }
    else
    {
        // Hide PrefsVC, Show MapVC.
        [self.mapVC setAnnotationsHidden:NO];

        // Bring back the Poor man's shadow for animation
        self.screenshot.layer.borderWidth = 1;
        self.screenshot.layer.shadowRadius = 0;
        [UIView animateWithDuration:.5
                         animations:^(void) {
                             CGAffineTransform rotation = CGAffineTransformMakeRotation(-.9*M_PI);
                             self.screenshot.transform = CGAffineTransformConcat(rotation, self.screenshot.transform);
                             self.screenshot.layer.borderWidth = 0;
                         } completion:^(BOOL finished) {
                             // We're done !
                             [self.screenshot removeFromSuperview];
                             self.screenshot = nil;
                             [self.rootNavC popToRootViewControllerAnimated:NO];
                         }];
    }
}
@end
