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
    [self.prefsVC didMoveToParentViewController:self];
    
    [self addChildViewController:self.mapVC];
    self.mapVC.view.frame = self.view.bounds;
    [self.view addSubview:self.mapVC.view];
    [self.mapVC didMoveToParentViewController:self];
    
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

    [self setupRotationCenter];
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

- (void) setupRotationCenter
{
    CGPoint rotationCenter = self.infoButton.center;
    self.mapVC.view.layer.anchorPoint = CGPointMake(rotationCenter.x/self.view.bounds.size.width,
                                                    rotationCenter.y/self.view.bounds.size.height);
    self.mapVC.view.layer.position = rotationCenter;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setMapVCShadow];
    [self setupRotationCenter];
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
    }

    self.helpVC.view.alpha = 1;
    [self addChildViewController:self.helpVC];
    [self.view addSubview:self.helpVC.view];
    self.helpVC.view.frame = self.view.bounds;
    [self.helpVC didMoveToParentViewController:self];
}


- (IBAction)closeHelp:(id)sender
{
    [UIView animateWithDuration:.5 animations:^{
        self.helpVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.helpVC willMoveToParentViewController:nil];
        [self.helpVC.view removeFromSuperview];
        [self.helpVC removeFromParentViewController];
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
    self.visibleViewController = self.prefsVC;

    CGFloat fromAngle = 0;
    CGFloat toAngle = .9*M_PI;

    [self animateMapsVCFromAngle:fromAngle toAngle:toAngle];
}

- (void) hidePrefs
{
    self.visibleViewController = self.mapVC;

    CGFloat fromAngle = .9*M_PI;
    CGFloat toAngle = 0;
    
    [self animateMapsVCFromAngle:fromAngle toAngle:toAngle];
}

- (void) animateMapsVCFromAngle:(CGFloat)fromAngle toAngle:(CGFloat)toAngle
{
    CGFloat totalDuration = .5f;

    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    id presentationValue = [self.mapVC.view.layer.presentationLayer valueForKey:@"transform"];
    id modelValue = [self.mapVC.view.layer.modelLayer valueForKey:@"transform"];
    
    CATransform3D presentationTransform = [presentationValue CATransform3DValue];
    CGFloat currentAngle = atan2f(presentationTransform.m12, presentationTransform.m11);
    
    animation.fromValue = presentationValue;
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate([modelValue CATransform3DValue], toAngle, 0, 0, 1)];
    animation.duration = totalDuration*((toAngle-currentAngle)/(toAngle-fromAngle));
    
    animation.fillMode = kCAFillModeBoth;
    animation.removedOnCompletion = NO;
    [self.mapVC.view.layer addAnimation:animation forKey:@"rotation"];
}

@end
