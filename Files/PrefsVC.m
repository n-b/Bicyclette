//
//  PrefsVC.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 14/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "PrefsVC.h"
#import "BicycletteCity+Update.h"
#import "CitiesController.h"
#import "NSProcessInfo+HardwareMachine.h"
#import "Style.h"
#import "UIBarButtonItem+BICMargins.h"

@implementation PrefsVC
{
    CitiesController * _controller;

    IBOutlet UITableViewCell * _rateOnAppStoreCell;
    IBOutlet UITableViewCell * _geofencesCell;
    IBOutlet UISwitch * _geofencesSwitch;
    IBOutlet UITableViewCell * _updateStationsCell;
    IBOutlet UIActivityIndicatorView * _updateIndicator;
    IBOutlet UITableViewCell * _emailSupportCell;
}

// Life cycle

+ (UIViewController*) prefsVCWithController:(CitiesController *)controller
{
    PrefsVC * prefsVC = [[UIStoryboard storyboardWithName:@"PrefsVC" bundle:nil] instantiateInitialViewController];
    prefsVC.controller = controller;
    UINavigationController * navC = [[UINavigationController alloc] initWithRootViewController:prefsVC];
    navC.navigationBar.barTintColor = kBicycletteBlue;
    navC.navigationBar.tintColor = [UIColor whiteColor];
    navC.navigationBar.barStyle = UIBarStyleBlack;
    navC.navigationBarHidden = NO;
    navC.toolbarHidden = YES;
    return navC;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.title = [NSString stringWithFormat:@"%@ %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPrefsVC)];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateBegan object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateGotNewData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateFailed object:nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_controller removeObserver:self forKeyPath:@"currentCity" context:(__bridge void *)([self class])];
}

- (void) setController:(CitiesController *)controller_
{
    [_controller removeObserver:self forKeyPath:@"currentCity" context:(__bridge void *)([self class])];
    _controller = controller_;
    [_controller addObserver:self forKeyPath:@"currentCity" options:NSKeyValueObservingOptionInitial context:(__bridge void *)([self class])];
}

// Data

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([self class])) {
        [self updateUpdateLabel];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// View Cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView.backgroundColor = kBicycletteBlue;
    
    _geofencesSwitch.onTintColor = kBicycletteBlue;
    
    _geofencesCell.textLabel.text = NSLocalizedString(@"ENABLE_GEOFENCES", nil);
    _geofencesCell.detailTextLabel.text = NSLocalizedString(@"GEOFENCES_UNAVAILABLE", nil);
    if([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]){
        _geofencesSwitch.enabled = YES;
    } else {
        _geofencesSwitch.enabled = NO;
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUpdateLabel];
    if(![_updateIndicator isAnimating]) {
        _updateStationsCell.textLabel.text = NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil);
    }
    _geofencesSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"RegionMonitoring.Enabled"];
}

- (IBAction)dismissPrefsVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Autorotation support
- (BOOL) shouldAutorotate { return YES; }
- (NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAll; }

// UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell==_updateStationsCell) {
        [self updateStationsList];
    } else if(cell==_emailSupportCell) {
        [self openEmailSupport];
    } else if(cell==_rateOnAppStoreCell) {
        [self rate:nil];
    }
}

// Actions

- (IBAction) openEmailSupport
{
    NSString * emailAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"SupportEmailAddress"];
    
    NSString * techSummary = [NSString stringWithFormat:NSLocalizedString(@"SUPPORT_EMAIL_TECH_SUMMARY_%@_%@_%@_%@", nil),
                              [NSString stringWithFormat:@"%@ (%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleVersionKey]],
                              [NSString stringWithFormat:@"%@ (%@)",[[UIDevice currentDevice] model], [[NSProcessInfo processInfo] hardwareMachine]],
                              [NSString stringWithFormat:@"%@ (%@)",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]],
                              _controller.currentCity.cityName?:@""
                              ];
    techSummary = [techSummary stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * emailLink = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", emailAddress, [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey], techSummary];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailLink]];
}

// City updates

- (IBAction)updateStationsList
{
    [_controller.currentCity update];
}

- (void) updateUpdateLabel
{
    if(_controller.currentCity) {
        _updateStationsCell.userInteractionEnabled = YES;
        _updateStationsCell.textLabel.enabled = YES;
        _updateStationsCell.detailTextLabel.enabled = YES;
        NSUInteger count = [_controller.currentCity.mainContext countForFetchRequest:[[NSFetchRequest alloc] initWithEntityName:[Station entityName]] error:NULL];
        _updateStationsCell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d STATION COUNT OF TYPE %@", nil),
                                                    count,
                                                    _controller.currentCity.title];
    } else {
        _updateStationsCell.userInteractionEnabled = NO;
        _updateStationsCell.textLabel.enabled = NO;
        _updateStationsCell.detailTextLabel.enabled = NO;
        _updateStationsCell.detailTextLabel.text = nil;
    }
}

- (void)cityDataUpdated:(NSNotification*)note
{
    if(note.object!=_controller.currentCity) {
        return;
    }
    
    if([note.name isEqualToString:BicycletteCityNotifications.updateBegan]) {
        // Began
        _updateStationsCell.userInteractionEnabled = NO;
        _updateStationsCell.textLabel.enabled = NO;
        _updateStationsCell.detailTextLabel.enabled = NO;
        _updateStationsCell.detailTextLabel.text = NSLocalizedString(@"UPDATING : FETCHING", nil);
        [_updateIndicator startAnimating];
    } else if([note.name isEqualToString:BicycletteCityNotifications.updateGotNewData]) {
        // Parsing
        _updateStationsCell.detailTextLabel.text = NSLocalizedString(@"UPDATING : PARSING", nil);
    } else if([note.name isEqualToString:BicycletteCityNotifications.updateSucceeded]) {
        // Success
        _updateStationsCell.userInteractionEnabled = YES;
        _updateStationsCell.textLabel.enabled = YES;
        _updateStationsCell.detailTextLabel.enabled = YES;
        _updateStationsCell.detailTextLabel.text = NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil);
        [_updateIndicator stopAnimating];
        [self updateUpdateLabel];
        NSArray * saveErrors = note.userInfo[BicycletteCityNotifications.keys.saveErrors];
        if ([saveErrors count]!=0
            && self.navigationController.visibleViewController==self) { //Only display error if visible
            NSString * message = [NSString stringWithFormat:@"%@\n%@.",
                       NSLocalizedString(@"UPDATING : COMPLETED WITH ERRORS", nil),
                       [[saveErrors valueForKey:@"localizedDescription"] componentsJoinedByString:@",\n"]];
            NSString * title = NSLocalizedString(@"UPDATING : COMPLETED", nil);
            [[[UIAlertView alloc] initWithTitle:title
                                        message:message
                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    } else if([note.name isEqualToString:BicycletteCityNotifications.updateFailed]) {
        // Failure
        _updateStationsCell.userInteractionEnabled = YES;
        _updateStationsCell.textLabel.enabled = YES;
        _updateStationsCell.detailTextLabel.enabled = YES;
        _updateStationsCell.detailTextLabel.text = NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil);
        [_updateIndicator stopAnimating];
        [self updateUpdateLabel];

        if(self.navigationController.visibleViewController==self) { //Only display error if visible
            NSError * error = note.userInfo[BicycletteCityNotifications.keys.failureError];
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UPDATING : FAILED",nil)
                                        message:[error localizedDescription]
                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}

// Share and Rate

- (NSURL*) appURLOnStore
{
    return [NSURL URLWithString:@"https://itunes.apple.com/us/app/bicyclette/id546171712?l=fr&ls=1&mt=8"];
}

- (IBAction)rate:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=546171712"]];
}

// Prefs

- (IBAction)switchRegionMonitoring:(UISwitch*)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"RegionMonitoring.Enabled"];
}


@end
