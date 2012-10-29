//
//  RootNavC.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/09/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "RootNavC.h"
#import "MapVC.h"
#import "PrefsVC.h"
#import "HelpVC.h"
#import "UIView+Screenshot.h"
#import "BicycletteCity.h"

@interface RootNavC ()
@property IBOutlet MapVC *mapVC;
@property IBOutlet PrefsVC *prefsVC;
@property IBOutlet HelpVC *helpVC;

@property UIImageView *screenshot;
@property IBOutlet UIToolbar *infoToolbar;
@property IBOutlet UIButton *infoButton;
@end

/****************************************************************************/
#pragma mark -

@implementation RootNavC

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/****************************************************************************/
#pragma mark -

- (void) setCities:(NSArray*)cities
{
    self.mapVC.cities = cities;
    self.prefsVC.cities = cities;
}

/****************************************************************************/
#pragma mark -

- (BOOL) shouldAutorotate
{
    // either the mapVC or the prefsVC
    return [[self visibleViewController] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

/****************************************************************************/
#pragma mark -

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // info button
    CGRect rootViewFrame = self.view.bounds;
    [self.view addSubview:self.infoToolbar];
    CGRect infoToolbarFrame = self.infoToolbar.frame;
    infoToolbarFrame.origin.x = rootViewFrame.size.width - infoToolbarFrame.size.width;
    infoToolbarFrame.origin.y = rootViewFrame.size.height - infoToolbarFrame.size.height;
    self.infoToolbar.frame = infoToolbarFrame;
    self.infoButton.center = self.infoToolbar.center;
    CGRect f = self.infoButton.frame;
    f.origin.y = lroundf(f.origin.y);
    self.infoButton.frame = f;
    [self.view addSubview:self.infoButton];    
}

- (void) applicationDidFinishLaunching:(NSNotification*)note
{
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
}

/****************************************************************************/
#pragma mark -

- (IBAction)showHelp
{
    if(self.visibleViewController!=self.mapVC)
    {
        [self hidePrefs];
        [self performSelector:_cmd withObject:nil afterDelay:.5];
    }
    else
    {
        [self.view addSubview:self.helpVC.view];
        [self.helpVC viewWillAppear:NO];
        self.helpVC.view.frame = self.view.bounds;
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

- (void) notifyCanRequestLocation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.canRequestLocation object:nil];
}


/****************************************************************************/
#pragma mark -

- (void) zoomInStation:(Station*)station
{
    [self.mapVC zoomInStation:station];
}

/****************************************************************************/
#pragma mark Prefs / Map Transition

- (IBAction)switchPrefs
{
    if(self.visibleViewController==self.mapVC)
        [self showPrefs];
    else
        [self hidePrefs];
}

- (void) showPrefs
{
    self.view.window.userInteractionEnabled = NO;
    
    UIView * rootView = self.view;
    // Hide MapVC, Show PrefsVC.
    [self.mapVC setAnnotationsHidden:YES];
    
    // Rotate around infoButton
    CGPoint rotationCenter = self.infoButton.center;
    
    // Take a screenshot of the mapVC view
    UIView * mapView = self.mapVC.view;
    self.screenshot = [[UIImageView alloc] initWithImage:[mapView screenshot]];
    
    // Present (not animated)
    [self pushViewController:self.prefsVC animated:NO];
    
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
                         self.view.window.userInteractionEnabled = YES;
                     }];
}

- (void) hidePrefs
{
    self.view.window.userInteractionEnabled = NO;
    
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
                         [self popToRootViewControllerAnimated:NO];
                         self.view.window.userInteractionEnabled = YES;
                     }];
}

@end
