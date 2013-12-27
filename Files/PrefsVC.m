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
#import "FanContainerViewController.h"
#import "NSProcessInfo+HardwareMachine.h"
#import "Style.h"

@interface PrefsVC () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property IBOutlet UIImageView *logoView;
@property IBOutlet UILabel *designAndCodeLabel;
@property IBOutlet UILabel *contactSupportButton;

@property IBOutlet UIToolbar *tweetBar;
@property IBOutlet UIButton *appstoreRatingsButton;

@property IBOutlet UILabel *enableGeofencesLabel;
@property IBOutlet UISwitch *geofencesSwitch;
@property IBOutlet UILabel *geofenceUnavailableLabel;

@property IBOutlet UIView *updateView;
@property IBOutlet UIActivityIndicatorView *updateIndicator;
@property IBOutlet UILabel *updateLabel;
@property IBOutlet UIButton *updateButton;

@property NSArray * products;
@end

/****************************************************************************/
#pragma mark -

@implementation PrefsVC

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTweetButton) name:ACAccountStoreDidChangeNotification object:nil];

    self.designAndCodeLabel.text = NSLocalizedString(@"DESIGN_AND_CODE", nil);
    self.contactSupportButton.text = NSLocalizedString(@"CONTACT_EMAIL_SUPPORT", nil);
    
    [self.appstoreRatingsButton setTitle:NSLocalizedString(@"APPSTORE_RATINGS_BUTTON", nil) forState:UIControlStateNormal];
    
    self.enableGeofencesLabel.text = NSLocalizedString(@"ENABLE_GEOFENCES", nil);
    self.geofencesSwitch.tintColor = [UIColor colorWithWhite:.1 alpha:1];
    self.geofencesSwitch.onTintColor = kBicycletteBlue;
    self.geofencesSwitch.layer.shadowOpacity = 1;
    self.geofencesSwitch.layer.shadowOffset = CGSizeMake(0, 1);
    self.geofencesSwitch.layer.shadowRadius = 0;
    self.geofencesSwitch.layer.shadowColor = [UIColor colorWithWhite:1 alpha:.5].CGColor;
    self.geofencesSwitch.layer.shouldRasterize = 1;
    self.geofenceUnavailableLabel.text = NSLocalizedString(@"GEOFENCES_UNAVAILABLE", nil);
    
    if([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]){
        self.geofenceUnavailableLabel.hidden = YES;
    } else {
        self.geofencesSwitch.hidden = YES;
        self.enableGeofencesLabel.hidden = YES;
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUpdateLabel];
    if(![self.updateIndicator isAnimating]) {
        [self.updateButton setTitle:NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil) forState:UIControlStateNormal];
    }
    self.geofencesSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"RegionMonitoring.Enabled"];
}

- (void) updateUpdateLabel
{
    self.updateLabel.text = [NSString stringWithFormat: NSLocalizedString(@"STATIONS_LIST_CITY_%@", nil),self.controller.currentCity.serviceName];
    
    // If the city can't update stations individually, it will update the whole list automatically.
    self.updateView.hidden = ! [self.controller.currentCity canUpdateIndividualStations];
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
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.section==1) {
        if(indexPath.row==0)
            [self openWebPage];
        else
            [self openEmailSupport];
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
    if(! [note.object canUpdateIndividualStations])
        return;
    
    if([note.name isEqualToString:BicycletteCityNotifications.updateBegan])
    {
        [self.updateButton setTitle:NSLocalizedString(@"UPDATING : FETCHING", nil) forState:UIControlStateNormal];
        [self.updateIndicator startAnimating];
        self.updateLabel.hidden = YES;
        self.updateButton.enabled = NO;
    }
    else if([note.name isEqualToString:BicycletteCityNotifications.updateGotNewData])
    {
        [self.updateButton setTitle:NSLocalizedString(@"UPDATING : PARSING", nil) forState:UIControlStateNormal];
    }
    else if([note.name isEqualToString:BicycletteCityNotifications.updateSucceeded])
    {
        [self.updateIndicator stopAnimating];
        self.updateLabel.hidden = NO;
        self.updateButton.enabled = YES;
        BOOL dataChanged = [note.userInfo[BicycletteCityNotifications.keys.dataChanged] boolValue];
        NSArray * saveErrors = note.userInfo[BicycletteCityNotifications.keys.saveErrors];
        if(dataChanged)
        {
            [self.updateButton setTitle:NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil)  forState:UIControlStateNormal];
            if([self isVisibleViewController])
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
            [self.updateButton setTitle:NSLocalizedString(@"UPDATING : NO NEW DATA", nil) forState:UIControlStateNormal];
    }
    else if([note.name isEqualToString:BicycletteCityNotifications.updateFailed])
    {
        [self.updateIndicator stopAnimating];
        self.updateLabel.hidden = NO;
        self.updateButton.enabled = YES;
        [self.updateButton setTitle:NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil) forState:UIControlStateNormal];
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

- (void) updateTweetButton
{
    self.tweetBar.hidden = ! [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (IBAction)tweet:(id)sender
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController * socialVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        NSString * message;
        if(self.controller.currentCity)
            message = [NSString stringWithFormat:NSLocalizedString(@"SHARE_BICYCLETTE_MESSAGE_CITY_%@", nil),self.controller.currentCity.serviceName];
        else
            message = NSLocalizedString(@"SHARE_BICYCLETTE_MESSAGE_GENERIC", nil);
        
        [socialVC setInitialText:message];
        [socialVC addURL:[self appURLOnStore]];
        [self presentViewController:socialVC animated:YES completion:nil];
    }
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

@end
