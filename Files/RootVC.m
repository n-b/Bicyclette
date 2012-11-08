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

@interface RootVC ()
@property IBOutlet HelpVC *helpVC;

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

- (void) setCitiesController:(CitiesController *)citiesController
{
    _citiesController = citiesController;
    ((MapVC*)self.frontViewController).citiesController = self.citiesController;
    citiesController.delegate = ((MapVC*)self.frontViewController);
    ((PrefsVC*)self.backViewController).cities = self.citiesController.cities;
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
    [self showFrontViewController];

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
    [(MapVC*)self.frontViewController zoomInStation:station];
}

@end
