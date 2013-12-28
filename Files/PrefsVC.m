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

@protocol UITableViewSection <NSObject> // Private API, lalalala. It's funny IB lets me connect outlets to it.
- (void) setHeaderTitle:(NSString*)title_;
- (void) setFooterTitle:(NSString*)title_;
@end

@implementation PrefsVC
{
    CitiesController * _controller;

    IBOutlet UITableViewCell * _geofencesCell;
    IBOutlet UISwitch * _geofencesSwitch;
    
    IBOutlet UITableViewCell * _updateStationsCell;
    IBOutlet UIActivityIndicatorView * _updateIndicator;

    IBOutlet UITableViewCell * _emailSupportCell;
    IBOutlet UITableViewCell * _rateOnAppStoreCell;
    
    IBOutlet id<UITableViewSection> _geofencesSection;
    IBOutlet id<UITableViewSection> _updateStationsSection;
    IBOutlet id<UITableViewSection> _supportSection;
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
    [_controller removeObserver:self forKeyPath:@"currentCity" context:__FILE__];
}

// Data
- (void) setController:(CitiesController *)controller_
{
    ;
    [_controller removeObserver:self forKeyPath:@"currentCity" context:__FILE__];
    _controller = controller_;
    [_controller addObserver:self forKeyPath:@"currentCity" options:NSKeyValueObservingOptionInitial context:__FILE__];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == __FILE__) {
        [self updateUpdateLabel];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// Autorotation support
- (BOOL) shouldAutorotate { return YES; }
- (NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAll; }

// View Cycle
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Geofences
    if([_geofencesSection respondsToSelector:@selector(setHeaderTitle:)]) {
        [_geofencesSection setHeaderTitle:NSLocalizedString(@"prefs.geofences.header",nil)];
    }
    _geofencesSwitch.onTintColor = kBicycletteBlue;
    _geofencesCell.textLabel.text = NSLocalizedString(@"prefs.geofences.enable", nil);
    if([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]){
        _geofencesSwitch.enabled = YES;
        _geofencesCell.detailTextLabel.text = nil;
    } else {
        _geofencesCell.detailTextLabel.text = NSLocalizedString(@"prefs.geofences.unavailable", nil);
        _geofencesSwitch.enabled = NO;
    }
    _geofencesSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"RegionMonitoring.Enabled"];
    if([_geofencesSection respondsToSelector:@selector(setFooterTitle:)]) {
        [_geofencesSection setFooterTitle:NSLocalizedString(@"prefs.geofences.footer",nil)];
    }

    // Updates
    if([_updateStationsSection respondsToSelector:@selector(setHeaderTitle:)]) {
        [_updateStationsSection setHeaderTitle:NSLocalizedString(@"prefs.updates.header",nil)];
    }
    _updateStationsCell.textLabel.text = NSLocalizedString(@"prefs.updates.update", nil);
    [self updateUpdateLabel];

    // Support
    if([_supportSection respondsToSelector:@selector(setHeaderTitle:)]) {
        [_supportSection setHeaderTitle:NSLocalizedString(@"prefs.support.header",nil)];
    }
    _emailSupportCell.textLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"SupportEmailAddress"];
    _emailSupportCell.textLabel.textColor = kBicycletteBlue;
    _rateOnAppStoreCell.textLabel.text = NSLocalizedString(@"prefs.support.seeOnAppStore", nil);
    if([_supportSection respondsToSelector:@selector(setFooterTitle:)]) {
        [_supportSection setFooterTitle:NSLocalizedString(@"prefs.support.footer",nil)];
    }
}

// UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0) {
        // Very hacky, at least it's short.
        // This tableviewcontroller is using stock UITableViewCell styles,
        // statically designed in a storyboard with autolayout support.
        // Why the hell do I need to do anything to have proper cell heights ?
        [_geofencesCell layoutIfNeeded];
        if([_geofencesCell.detailTextLabel.text length]) {
            return CGRectGetMaxY(_geofencesCell.detailTextLabel.frame) - CGRectGetMinY(_geofencesCell.textLabel.frame) + 16;
        } else {
            return CGRectGetHeight(_geofencesCell.textLabel.frame) + 16;
        }
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

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

/****************************************************************************/
#pragma mark Actions

- (IBAction)dismissPrefsVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Geofences

- (IBAction)switchRegionMonitoring:(UISwitch*)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"RegionMonitoring.Enabled"];
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

// Support

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

- (NSURL*) appURLOnStore
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", @"546171712"]];
}

- (IBAction)rate:(id)sender
{
    [[UIApplication sharedApplication] openURL:[self appURLOnStore]];
}

@end
