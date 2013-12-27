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
#import "BicycletteCity.h"
#import "CitiesController.h"
#import "UIApplication+LocalAlerts.h"

@interface RootVC () <UIAlertViewDelegate>
@end

/****************************************************************************/
#pragma mark -

@implementation RootVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyCanRequestLocation) name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void) notifyCanRequestLocation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.canRequestLocation object:nil];
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
    MapVC * mapVC = (MapVC*)[(UINavigationController*)self.frontViewController visibleViewController];
    mapVC.controller = self.citiesController;
    citiesController.delegate = mapVC;
    PrefsVC * prefsVC = (PrefsVC*)self.backViewController;
    prefsVC.controller = self.citiesController;
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

- (CGPoint) rotationCenter
{
    return self.infoButton.center;
}

- (void) notifyCanRequestLocation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.canRequestLocation object:nil];
}

@end
