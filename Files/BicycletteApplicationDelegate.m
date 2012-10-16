//
//  BicycletteApplicationDelegate.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteApplicationDelegate.h"
#import "ParisVelibCity.h"
#import "MarseilleLeveloCity.h"
#import "ToulouseVeloCity.h"
#import "DataUpdater.h"
#import "MapVC.h"
#import "PrefsVC.h"
#import "HelpVC.h"
#import "UIView+Screenshot.h"
#import "Station.h"

/****************************************************************************/
#pragma mark Private Methods

@interface BicycletteApplicationDelegate()
@property BicycletteCity * city;

@property IBOutlet UINavigationController *rootNavC;
@property IBOutlet MapVC *mapVC;
@property IBOutlet PrefsVC *prefsVC;
@property IBOutlet HelpVC *helpVC;

@property UIImageView *screenshot;
@property IBOutlet UIToolbar *infoToolbar;
@property IBOutlet UIButton *infoButton;
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
    
    // Create city
    self.city = [ParisVelibCity new];
    self.mapVC.city = self.city;
    self.prefsVC.city = self.city;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController = self.rootNavC;
    
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
    if( ([NSUserDefaults.standardUserDefaults boolForKey:@"DisplayHelpAtLaunch"]||
        [NSUserDefaults.standardUserDefaults boolForKey:@"DebugDisplayHelpAtLaunch"])
       && !([NSUserDefaults.standardUserDefaults boolForKey:@"DebugScreenshotForDefault"]||
            [NSUserDefaults.standardUserDefaults boolForKey:@"DebugScreenshotForITC"]) )
    {
        [self showHelp];
    }
    else
    {
        [self notifyCanRequestLocation];
    }
    
    if([NSUserDefaults.standardUserDefaults boolForKey:@"DebugScreenshotForITC2"])
    {
        UILocalNotification * userLocalNotif = [UILocalNotification new];
        userLocalNotif.hasAction = NO;
        userLocalNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
        userLocalNotif.alertBody = @"28 vélos, 2 places à Saint Severin";
        [[UIApplication sharedApplication] scheduleLocalNotification:userLocalNotif];
        userLocalNotif.alertBody = @"32 vélos, 1 places à Saint Michel Danton";
        [[UIApplication sharedApplication] scheduleLocalNotification:userLocalNotif];
        userLocalNotif.alertBody = @"20 vélos, 23 places à Saint Germain Harpe";
        [[UIApplication sharedApplication] scheduleLocalNotification:userLocalNotif];
    }
    
	return YES;
}

- (void) notifyCanRequestLocation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.canRequestLocation object:nil];
}

- (IBAction)showHelp
{
    if(self.rootNavC.visibleViewController!=self.mapVC)
    {
        [self hidePrefs];
        [self performSelector:_cmd withObject:nil afterDelay:.5];
    }
    else
    {
        [self.rootNavC.view addSubview:self.helpVC.view];
        [self.helpVC viewWillAppear:NO];
        self.helpVC.view.frame = self.rootNavC.view.bounds;
        [self.helpVC viewDidAppear:NO];
    }
}


- (IBAction)closeHelp:(id)sender
{
    [UIView animateWithDuration:.5 animations:^{
        self.helpVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.helpVC.view removeFromSuperview];
        self.helpVC.view.alpha = 1;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DisplayHelpAtLaunch"];
        [self notifyCanRequestLocation];
    }];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSString * number = notification.userInfo[@"stationNumber"];
    if(number)
    {
        Station * station = [self.city stationWithNumber:number];
        [self.mapVC zoomInStation:station];
    }
}

/****************************************************************************/
#pragma mark Prefs / Map Transition

- (IBAction)switchPrefs
{
    if(self.rootNavC.visibleViewController==self.mapVC)
        [self showPrefs];
    else
        [self hidePrefs];
}

- (void) showPrefs
{
    self.window.userInteractionEnabled = NO;

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
                         self.window.userInteractionEnabled = YES;
                     }];
}

- (void) hidePrefs
{
    self.window.userInteractionEnabled = NO;

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
                         self.window.userInteractionEnabled = YES;
                     }];
}

@end
