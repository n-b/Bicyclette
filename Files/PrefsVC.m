//
//  PrefsVC.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 14/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "PrefsVC.h"
#import "BicycletteCity+Update.h"
#import "Store.h"
#import "CitiesController.h"
#import "FanContainerViewController.h"
#import "NSProcessInfo+HardwareMachine.h"
#import "Style.h"

@interface PrefsVC () <StoreDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property IBOutlet UIScrollView *scrollView;
@property IBOutlet UIView *contentView;
@property IBOutletCollection(UITableViewCell) NSArray *cells;

@property IBOutlet UIImageView *logoView;
@property IBOutlet UIView *logoShadowView;
@property IBOutlet UILabel *designAndCodeLabel;
@property IBOutlet UILabel *contactSupportButton;

@property IBOutlet UILabel *storeLabel;
@property IBOutlet UIActivityIndicatorView *storeIndicator;
@property IBOutlet UIBarButtonItem *storeButton;
@property IBOutlet UILabel *rewardLabel;

@property IBOutlet UIToolbar *tweetBar;
@property IBOutlet UIBarButtonItem *appstoreRatingsButton;

@property IBOutlet UILabel *seeHelpLabel;
@property IBOutlet UIBarButtonItem *seeHelpButton;

@property IBOutlet UILabel *enableGeofencesLabel;
@property IBOutlet UISwitch *geofencesSwitch;
@property IBOutlet UILabel *geofenceUnavailableLabel;

@property IBOutlet UIView *updateView;
@property IBOutlet UIActivityIndicatorView *updateIndicator;
@property IBOutlet UILabel *updateLabel;
@property IBOutlet UIBarButtonItem *updateButton;
@property IBOutlet UIToolbar *updateButtonBar;

@property Store * store;
@property NSArray * products;
@end

/****************************************************************************/
#pragma mark -

@implementation PrefsVC

- (void)awakeFromNib
{
    [super awakeFromNib];

    // Create store
    self.store = [Store new];
    self.store.delegate = self;
    
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

    [self updateViewAlignment:self.interfaceOrientation];

    self.logoView.layer.cornerRadius = 9;
    self.logoShadowView.layer.shadowOpacity = 1;
    self.logoShadowView.layer.shadowOffset = CGSizeMake(0, 1);
    self.logoShadowView.layer.shadowRadius = 1;
    self.logoShadowView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
    self.logoShadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.logoShadowView.bounds cornerRadius:9].CGPath;

    self.designAndCodeLabel.text = NSLocalizedString(@"DESIGN_AND_CODE", nil);
    self.contactSupportButton.text = NSLocalizedString(@"CONTACT_EMAIL_SUPPORT", nil);
    
    self.appstoreRatingsButton.title = NSLocalizedString(@"APPSTORE_RATINGS_BUTTON", nil);

    self.seeHelpLabel.text = NSLocalizedString(@"SEE_HELP_LABEL", nil);
    self.seeHelpButton.title = NSLocalizedString(@"SEE_HELP_BUTTON", nil);
    
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
    if(![self.updateIndicator isAnimating])
        [self.updateButton setTitle:NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil)];
    [self updateStoreButton];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    [self updateViewAlignment:toInterfaceOrientation];
}

- (void) updateViewAlignment:(UIInterfaceOrientation)interfaceOrientation
{
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(self.contentView.frame),self.scrollView.bounds.size.width);
    CGFloat yMargin;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
            yMargin = 300;
        else
            yMargin = 200;
    } else {
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
            yMargin = 80;
        else
            yMargin = 40;
    }
    self.scrollView.contentInset = UIEdgeInsetsMake(yMargin, 0, yMargin, 0);
}


/****************************************************************************/
#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (self.cells)[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row==0)
        [self openWebPage];
    else
        [self openEmailSupport];
}

/****************************************************************************/
#pragma mark Actions

- (IBAction)openWebPage {
    NSString * webpageURL = [[NSUserDefaults standardUserDefaults] stringForKey:@"WebpageURL"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webpageURL]];
}

- (IBAction)openEmailSupport {
    NSString * emailAddress;
    NSString * purchasedProductIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"PurchasedProductsIdentifier"];
    if(purchasedProductIdentifier!=nil)
        emailAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"SupportWithLoveEmailAddress"];
    else
        emailAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"SupportEmailAddress"];
    
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
        [self.updateButton setTitle:NSLocalizedString(@"UPDATING : FETCHING", nil)];
        [self.updateIndicator startAnimating];
        self.updateLabel.hidden = YES;
        self.updateButton.enabled = NO;
    }
    else if([note.name isEqualToString:BicycletteCityNotifications.updateGotNewData])
    {
        [self.updateButton setTitle:NSLocalizedString(@"UPDATING : PARSING", nil)];
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
            [self.updateButton setTitle:NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil)];
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
            [self.updateButton setTitle:NSLocalizedString(@"UPDATING : NO NEW DATA", nil)];
    }
    else if([note.name isEqualToString:BicycletteCityNotifications.updateFailed])
    {
        [self.updateIndicator stopAnimating];
        self.updateLabel.hidden = NO;
        self.updateButton.enabled = YES;
        [self.updateButton setTitle:NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil)];
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

/****************************************************************************/
#pragma mark Store updates

- (void) updateStoreButton
{
    NSString * purchasedProductIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"PurchasedProductsIdentifier"];
    
    self.storeLabel.text = purchasedProductIdentifier==nil ? NSLocalizedString(@"STORE_PLEASE_HELP_LABEL", nil) : NSLocalizedString(@"STORE_THANK_YOU_LABEL", nil);
    self.storeButton.title = purchasedProductIdentifier==nil ? NSLocalizedString(@"STORE_PLEASE_HELP_BUTTON", nil) : @"";
    self.rewardLabel.text = purchasedProductIdentifier==nil ? @"" : NSLocalizedString([self productsAndRewards][purchasedProductIdentifier], nil);
    self.storeButton.enabled = purchasedProductIdentifier==nil;
}

- (NSDictionary*) productsAndRewards
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"ProductsAndRewards"];
}

#pragma mark - // Begin Store Action

- (IBAction)donate {
    self.products = nil;
    BOOL didRequest = [self.store requestProducts:[[self productsAndRewards] allKeys]];
    if(didRequest)
    {
        [self.storeIndicator startAnimating];
        self.storeLabel.hidden = YES;
        self.storeButton.enabled = NO;
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STORE_UNAVAILABLE_TITLE", nil)
                                    message:NSLocalizedString(@"STORE_UNAVAILABLE_MESSAGE", nil)
                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"STORE_ALERT_CANCELx", nil) otherButtonTitles:nil] show];
    }
}

// List Products
- (void) store:(Store*)store productsRequestDidFailWithError:(NSError*)error
{
    [self.storeIndicator stopAnimating];
    self.storeLabel.hidden = NO;
    self.storeButton.enabled = YES;
    [[[UIAlertView alloc] initWithTitle:error.localizedDescription
                                message:error.localizedFailureReason
                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void) store:(Store*)store productsRequestDidComplete:(NSArray*)products
{
    self.products = [products sortedArrayUsingComparator:^NSComparisonResult(SKProduct* product1, SKProduct* product2) {
        return [product1.price compare:product2.price];
    }];

    UIActionSheet * storeSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"STORE_SHEET_TITLE", nil)
                                                             delegate:self
                                                    cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

    NSNumberFormatter *priceFormatter = [NSNumberFormatter new];
    priceFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    priceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;

    for (SKProduct * product in self.products) {
        priceFormatter.locale = product.priceLocale;
        [storeSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ - %@",product.localizedTitle,[priceFormatter stringFromNumber:product.price]]];
    }
    
    [storeSheet addButtonWithTitle:NSLocalizedString(@"STORE_RESTORE_PURCHASES", nil)];
    [storeSheet addButtonWithTitle:NSLocalizedString(@"STORE_SHEET_CANCEL", nil)];
    storeSheet.cancelButtonIndex = storeSheet.numberOfButtons-1;
    
    [storeSheet showInView:self.view];
}

// Pick a product
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==actionSheet.cancelButtonIndex) {
        [self actionSheetCancel:actionSheet];
    } else if(buttonIndex==actionSheet.numberOfButtons-2) {
        [self.store restore];
    } else {
        SKProduct * product = self.products[buttonIndex];
        [self.store buy:product];
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [self.storeIndicator stopAnimating];
    self.storeLabel.hidden = NO;
    self.storeButton.enabled = YES;
    self.products = nil;
}

#pragma mark -
// Transaction end
- (void) store:(Store*)store purchaseSucceeded:(NSString*)productIdentifier
{
    [[NSUserDefaults standardUserDefaults] setObject:productIdentifier forKey:@"PurchasedProductsIdentifier"];
    [self.storeIndicator stopAnimating];
    self.storeLabel.hidden = NO;
    self.storeButton.enabled = YES;
    self.products = nil;
    [self updateStoreButton];
}

- (void) store:(Store*)store purchaseCancelled:(NSString*)productIdentifier
{
    [self.storeIndicator stopAnimating];
    self.storeLabel.hidden = NO;
    self.storeButton.enabled = YES;
    self.products = nil;
}

- (void) store:(Store*)store purchaseFailed:(NSString*)productIdentifier withError:(NSError*)error
{
    [self.storeIndicator stopAnimating];
    self.storeLabel.hidden = NO;
    self.storeButton.enabled = YES;
    self.products = nil;
    // StoreKit already presents the error, it's useless to display another alert
}

- (void) storeRestoreFinished:(Store*)store
{
    [self.storeIndicator stopAnimating];
    self.storeLabel.hidden = NO;
    self.storeButton.enabled = YES;
    self.products = nil;
    [self updateStoreButton];
}

@end
