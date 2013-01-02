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
#import "CitiesController.h"

/****************************************************************************/
#pragma mark -

@implementation RootVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
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

- (void) setCitiesController:(CitiesController *)citiesController
{
    _citiesController = citiesController;
    ((MapVC*)self.frontViewController).controller = self.citiesController;
    ((PrefsVC*)self.backViewController).controller = self.citiesController;
    citiesController.delegate = ((MapVC*)self.frontViewController);
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

    [super viewDidLoad];

    [self.view bringSubviewToFront:self.infoToolbar];
    [self.view bringSubviewToFront:self.infoButton];
}

-(CGPoint) rotationCenter
{
    return self.infoButton.center;
}
/****************************************************************************/
#pragma mark -

- (IBAction)showHelp
{
    [self showFrontViewControllerAnimated:YES completion:^{
        [self addChildViewController:self.helpVC];
        [self.view addSubview:self.helpVC.view];
        self.helpVC.view.frame = self.view.bounds;
        self.helpVC.view.alpha = 0;
        [self.helpVC didMoveToParentViewController:self];
        [UIView animateWithDuration:.5 animations:^{
            self.helpVC.view.alpha = 1;
        }];
    }];
}


- (void) helpFinished:(HelpVC *)helpVC
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

@end
