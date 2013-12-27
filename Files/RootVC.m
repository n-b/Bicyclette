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
                                                 selector:@selector(showHelpIfNeeded) name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(askForDonationIfNeeded) name:UIApplicationDidBecomeActiveNotification
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

/****************************************************************************/
#pragma mark -


- (void) showHelpIfNeeded
{
#if ! SCREENSHOTS
    // Show help at first launch
    if([NSUserDefaults.standardUserDefaults boolForKey:@"DisplayHelpAtLaunch"]||
       [NSUserDefaults.standardUserDefaults boolForKey:@"DebugDisplayHelpAtLaunch"])
    {
        [self showHelpAnimated:NO];
    }
    else
    {
        [self notifyCanRequestLocation];
    }
#endif
}

- (IBAction)showHelp
{
    [self showHelpAnimated:YES];
}

- (void) showHelpAnimated:(BOOL)animated
{
    [self showFrontViewControllerAnimated:YES completion:^{
        [self addChildViewController:self.helpVC];
        [self.view addSubview:self.helpVC.view];
        self.helpVC.view.frame = self.view.bounds;
        self.helpVC.view.alpha = 0;
        [self.helpVC didMoveToParentViewController:self];
        [UIView animateWithDuration:animated?0.5f:0.f animations:^{
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

/****************************************************************************/
#pragma mark Donation Request Alert

- (void) askForDonationIfNeeded
{
    NSMutableArray * lastLaunches = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"Bicyclette.App.LastLaunches"]];
    NSTimeInterval intervalBetweenTwoLaunches = 24*60*60;
    NSUInteger minCountInDonationInterval = 3;
    NSTimeInterval donationInterval = 24*60*60*10;

    NSDate * now = [NSDate date];
    if([now timeIntervalSinceReferenceDate] - [[lastLaunches lastObject] timeIntervalSinceReferenceDate] > intervalBetweenTwoLaunches)
    {
        [lastLaunches addObject:now];
    }
    while( [lastLaunches count] > minCountInDonationInterval)
    {
        [lastLaunches removeObjectAtIndex:0];
    }
    
    BOOL shouldAsk = NO;
    if([lastLaunches count] == minCountInDonationInterval && [[lastLaunches lastObject] timeIntervalSinceReferenceDate] - [[lastLaunches objectAtIndex:0] timeIntervalSinceReferenceDate] < donationInterval)
    {
        shouldAsk = YES;
        lastLaunches = [NSMutableArray array];
    }
    [[NSUserDefaults standardUserDefaults] setObject:lastLaunches forKey:@"Bicyclette.App.LastLaunches"];
    
    if(shouldAsk)
    {
#if DEBUG
        NSString * purchasedProduct = [[NSUserDefaults standardUserDefaults] objectForKey:@"DebugPurchasedProductsIdentifier"];
#else
        NSString * purchasedProduct = [[NSUserDefaults standardUserDefaults] objectForKey:@"PurchasedProductsIdentifier"];
#endif
        if([purchasedProduct length] != 0)
        {
            NSString * reward = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"ProductsAndRewards"][purchasedProduct];
            [self.frontViewController displayBannerTitle:NSLocalizedString(@"STORE_THANK_YOU_LABEL", nil) subtitle:NSLocalizedString(reward, nil) sticky:NO];
        }
        else
        {
            [self presentDonationAlertWithDelayOption:YES];
        }
    }
}

- (void) presentDonationAlertWithDelayOption:(BOOL)delayOption
{
    UIAlertView * donationAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STORE_ALERT_TITLE", nil)
                                                             message:NSLocalizedString(@"STORE_ALERT_MESSAGE", nil)
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"STORE_ALERT_CANCEL", nil)
                                                   otherButtonTitles:NSLocalizedString(@"STORE_ALERT_OK", nil),
                                   delayOption?NSLocalizedString(@"STORE_ALERT_IN_20_MINUTES", nil):nil,nil];
    [donationAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==alertView.firstOtherButtonIndex){ // "Donate"
        [self showBackViewControllerAnimated:YES completion:^{
            [((PrefsVC*)self.backViewController) donate];
        }];
    } else if(buttonIndex==alertView.firstOtherButtonIndex+1){ // Ask me in 20 minutes
        [self askMeToDonateLater];
    } else { // Not now
    }
}

- (void) askMeToDonateLater
{
    NSTimeInterval donationDelay = [[NSUserDefaults standardUserDefaults] doubleForKey:@"Store.DonationAlertDelay"];
    [[UIApplication sharedApplication] presentLocalNotificationMessage:NSLocalizedString(@"STORE_ALERT_TITLE", nil)
                                                           alertAction:NSLocalizedString(@"STORE_ALERT_OK", nil)
                                                             soundName:nil
                                                              userInfo:@{@"type": @"donationrequest"}
                                                              fireDate:[NSDate dateWithTimeIntervalSinceNow:donationDelay]];
}

- (void) handleDonationNotification:(UILocalNotification*)notification
{
    [self presentDonationAlertWithDelayOption:NO];
}


@end
