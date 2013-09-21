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
    CGRect rootViewBounds = self.view.bounds;
    CGSize infoButtonSize = self.infoButton.bounds.size;
    
    self.infoButton.center = CGPointMake(CGRectGetMaxX(rootViewBounds) - infoButtonSize.width - 8,
                                         CGRectGetMaxY(rootViewBounds) - infoButtonSize.height);
    [self.view addSubview:self.infoButton];

    [super viewDidLoad];

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
