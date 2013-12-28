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

@interface PrefsVC () <UITableViewDataSource, UITableViewDelegate>
@end

/****************************************************************************/
#pragma mark -

@implementation PrefsVC
{
    IBOutlet UITableViewCell * _appIconCell;
    
    IBOutlet UITableViewCell * _rateOnAppStoreCell;
    IBOutlet UITableViewCell * _designAndCodeCell;

    IBOutlet UITableViewCell * _geofencesCell;
    IBOutlet UISwitch * _geofencesSwitch;
    IBOutlet UILabel * _enableGeofencesLabel;
    IBOutlet UILabel * _geofenceUnavailableLabel;

    IBOutlet UITableViewCell * _updateStationsCell;
    IBOutlet UILabel * _updateLabel;
    IBOutlet UIActivityIndicatorView * _updateIndicator;
    
    IBOutlet UITableViewCell * _emailSupportCell;
    
}

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

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateBegan object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateGotNewData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDataUpdated:) name:BicycletteCityNotifications.updateFailed object:nil];
    }

- (void)dealloc
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([self class]))
        [self updateUpdateLabel];
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

/****************************************************************************/
#pragma mark View Cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _appIconCell.backgroundColor = kBicycletteBlue;
    _appIconCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 1000);
        
    _enableGeofencesLabel.text = NSLocalizedString(@"ENABLE_GEOFENCES", nil);
    _geofencesSwitch.onTintColor = kBicycletteBlue;
    _geofenceUnavailableLabel.text = NSLocalizedString(@"GEOFENCES_UNAVAILABLE", nil);
    
    if([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]){
        _geofenceUnavailableLabel.hidden = YES;
    } else {
        _geofencesSwitch.hidden = YES;
        _enableGeofencesLabel.hidden = YES;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPrefsVC)];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUpdateLabel];
    if(![_updateIndicator isAnimating]) {
        _updateLabel.text = NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil);
    }
    _geofencesSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"RegionMonitoring.Enabled"];
}

- (void) updateUpdateLabel
{
    _updateLabel.text = [NSString stringWithFormat: NSLocalizedString(@"STATIONS_LIST_CITY_%@", nil),self.controller.currentCity.serviceName];
}

/****************************************************************************/
#pragma mark Autorotation support

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

/****************************************************************************/
#pragma mark TableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell==_geofencesCell) {
        [_geofencesSwitch setOn:!_geofencesSwitch.on animated:YES];
        [self switchRegionMonitoring:_geofencesSwitch];
    } else if(cell==_updateStationsCell) {
        [self updateStationsList];
    } else if(cell==_emailSupportCell) {
        [self openEmailSupport];
    } else if(cell==_rateOnAppStoreCell) {
        [self rate:nil];
    } else if(cell==_designAndCodeCell) {
        [self openWebPage];
    }
}

/****************************************************************************/
#pragma mark Actions

- (IBAction)openWebPage {
    NSString * webpageURL = [[NSUserDefaults standardUserDefaults] stringForKey:@"WebpageURL"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webpageURL]];
}

- (IBAction)openEmailSupport {
    NSString * emailAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"SupportEmailAddress"];
    
    NSString * techSummary = [NSString stringWithFormat:NSLocalizedString(@"SUPPORT_EMAIL_TECH_SUMMARY_%@_%@_%@_%@", nil),
                              [NSString stringWithFormat:@"%@ (%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleVersionKey]],
                              [NSString stringWithFormat:@"%@ (%@)",[[UIDevice currentDevice] model], [[NSProcessInfo processInfo] hardwareMachine]],
                              [NSString stringWithFormat:@"%@ (%@)",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]],
                              self.controller.currentCity.cityName?:@""
                              ];
    techSummary = [techSummary stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * emailLink = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", emailAddress, [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey], techSummary];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailLink]];
}

/****************************************************************************/
#pragma mark City updates

- (IBAction)updateStationsList
{
    [self.controller.currentCity update];
}

- (void)cityDataUpdated:(NSNotification*)note
{
    if(note.object!=self.controller.currentCity)
        return;
    
    if([note.name isEqualToString:BicycletteCityNotifications.updateBegan])
    {
        _updateLabel.text = NSLocalizedString(@"UPDATING : FETCHING", nil);
        [_updateIndicator startAnimating];
        _updateLabel.hidden = YES;
    }
    else if([note.name isEqualToString:BicycletteCityNotifications.updateGotNewData])
    {
        _updateLabel.text = NSLocalizedString(@"UPDATING : PARSING", nil);
    }
    else if([note.name isEqualToString:BicycletteCityNotifications.updateSucceeded])
    {
        [_updateIndicator stopAnimating];
        _updateLabel.hidden = NO;
        BOOL dataChanged = [note.userInfo[BicycletteCityNotifications.keys.dataChanged] boolValue];
        NSArray * saveErrors = note.userInfo[BicycletteCityNotifications.keys.saveErrors];
        if(dataChanged)
        {
            _updateLabel.text = NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil);
            if(self.navigationController.visibleViewController == self)
            {
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[Station entityName]];
                NSUInteger count = [self.controller.currentCity.mainContext countForFetchRequest:request error:NULL];
                NSString * title;
                NSString * message = [NSString stringWithFormat:NSLocalizedString(@"%d STATION COUNT OF TYPE %@", nil),
                                      count,
                                      self.controller.currentCity.title];
                if(nil==saveErrors)
                {
                    title = NSLocalizedString(@"UPDATING : COMPLETED", nil);
                }
                else
                {
                    message = [message stringByAppendingFormat:@"\n\n%@\n%@.",
                               NSLocalizedString(@"UPDATING : COMPLETED WITH ERRORS", nil),
                               [[saveErrors valueForKey:@"localizedDescription"] componentsJoinedByString:@",\n"]];
                    title = NSLocalizedString(@"UPDATING : COMPLETED", nil);
                }
                [[[UIAlertView alloc] initWithTitle:title
                                            message:message
                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
        else
            _updateLabel.text = NSLocalizedString(@"UPDATING : NO NEW DATA", nil);
    }
    else if([note.name isEqualToString:BicycletteCityNotifications.updateFailed])
    {
        [_updateIndicator stopAnimating];
        _updateLabel.hidden = NO;
        _updateLabel.text = NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil);
        NSError * error = note.userInfo[BicycletteCityNotifications.keys.failureError];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UPDATING : FAILED",nil) 
                                   message:[error localizedDescription]
                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

/****************************************************************************/
#pragma mark - Share and Rate

- (NSURL*) appURLOnStore
{
    return [NSURL URLWithString:@"https://itunes.apple.com/us/app/bicyclette/id546171712?l=fr&ls=1&mt=8"];
}

- (IBAction)rate:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=546171712"]];
}

/****************************************************************************/
#pragma mark Prefs

- (IBAction)switchRegionMonitoring:(UISwitch*)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"RegionMonitoring.Enabled"];
}


- (IBAction)dismissPrefsVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
