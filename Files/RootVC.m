//
//  RootNavC.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/09/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "RootVC.h"
#import "MapVC.h"
#import "PrefsVC.h"
#import "HelpVC.h"
#import "UIView+Screenshot.h"
#import "BicycletteCity.h"

@interface RootVC ()
@property IBOutlet MapVC *mapVC;
@property IBOutlet PrefsVC *prefsVC;
@property IBOutlet HelpVC *helpVC;
@property UIViewController * visibleViewController;

@property IBOutlet UIToolbar *infoToolbar;
@property IBOutlet UIButton *infoButton;
@end

/****************************************************************************/
#pragma mark -

@implementation RootVC

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

- (void) applicationDidFinishLaunching:(NSNotification*)note
{
    // Show help at first launch
    if([NSUserDefaults.standardUserDefaults boolForKey:@"DisplayHelpAtLaunch"]||
       [NSUserDefaults.standardUserDefaults boolForKey:@"DebugDisplayHelpAtLaunch"])
    {
        [self showHelp];
    }
    else
    {
        [self notifyCanRequestLocation];
    }
}

/****************************************************************************/
#pragma mark -

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // ViewControllers
    
    [self addChildViewController:self.prefsVC];
    self.prefsVC.view.frame = self.view.bounds;
    [self.view addSubview:self.prefsVC.view];
    
    [self addChildViewController:self.mapVC];
    self.mapVC.view.frame = self.view.bounds;
    [self.view addSubview:self.mapVC.view];
    
    self.visibleViewController = self.mapVC;
    
    self.mapVC.view.layer.shadowOffset = CGSizeZero;
    self.mapVC.view.layer.shadowOpacity = 1;
    [self setMapVCShadow];

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

- (BOOL) shouldAutorotate
{
    // either the mapVC or the prefsVC
    return [[self visibleViewController] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setMapVCShadow];
}

- (void) setMapVCShadow
{
    self.mapVC.view.layer.shadowPath = (__bridge CGPathRef)(CFBridgingRelease(CGPathCreateWithRect(self.mapVC.view.layer.bounds, NULL)));
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
    
    // Hide MapVC, Show PrefsVC.
    
    // Rotate around infoButton
    CGPoint rotationCenter = self.infoButton.center;
    // Align the mapVC around the rotation center
    self.mapVC.view.layer.anchorPoint = CGPointMake(rotationCenter.x/self.view.bounds.size.width,
                                                    rotationCenter.y/self.view.bounds.size.height);
    self.mapVC.view.transform = CGAffineTransformMakeTranslation(rotationCenter.x-CGRectGetMidX(self.mapVC.view.bounds),
                                                                 rotationCenter.y-CGRectGetMidY(self.mapVC.view.bounds));
    
    // Present (not animated)
    self.visibleViewController = self.prefsVC;
    
    // Animate
    [UIView animateWithDuration:.5
                     animations:^(void) {
                         CGAffineTransform rotation = CGAffineTransformMakeRotation(.9*M_PI);
                         self.mapVC.view.transform = CGAffineTransformConcat(rotation, self.mapVC.view.transform);
                     } completion:^(BOOL finished) {
                         self.view.window.userInteractionEnabled = YES;
                     }];
}

- (void) hidePrefs
{
    self.view.window.userInteractionEnabled = NO;
    
    // Hide PrefsVC, Show MapVC.
    [self.mapVC setAnnotationsHidden:NO];
    
    [UIView animateWithDuration:.5
                     animations:^(void) {
                         CGAffineTransform rotation = CGAffineTransformMakeRotation(-.9*M_PI);
                         self.mapVC.view.transform = CGAffineTransformConcat(rotation, self.mapVC.view.transform);
                     } completion:^(BOOL finished) {
                         self.visibleViewController = self.mapVC;
                         self.mapVC.view.layer.anchorPoint = CGPointMake(.5f,.5f);
                         self.mapVC.view.transform = CGAffineTransformIdentity;

                         self.view.window.userInteractionEnabled = YES;
                     }];
}

@end
