//
//  PrefsVC.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 14/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "PrefsVC.h"
#import "VelibModel.h"
#import "Store.h"
#import "Station.h"

@interface PrefsVC () <StoreDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (strong) IBOutletCollection(UITableViewCell) NSArray *cells;

@property (weak) IBOutlet UISegmentedControl *radarDistanceSegmentedControl;

@property (weak) IBOutlet UIActivityIndicatorView *updateIndicator;
@property (weak) IBOutlet UIBarButtonItem *updateButton;
@property (weak) IBOutlet UIActivityIndicatorView *storeIndicator;
@property (weak) IBOutlet UIBarButtonItem *storeButton;

@property (strong) Store * store;
@property NSArray * products;
@end

@implementation PrefsVC

- (void)awakeFromNib
{
    [super awakeFromNib];

    // Create store
    self.store = [Store new];
    self.store.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateRadarDistancesSegmentedControl];
    if(![self.updateIndicator isAnimating])
        [self.updateButton setTitle:NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil)];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
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
        [self openDesignPage];
    else
        [self openSourcePage];
}

/****************************************************************************/
#pragma mark Actions

- (IBAction)openDesignPage {
    NSString * designURL = [NSString stringWithFormat:@"http://%@",[[NSBundle mainBundle] infoDictionary][@"designURL"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:designURL]];    
}

- (IBAction)openSourcePage {
    NSString * sourceURL = [NSString stringWithFormat:@"http://%@",[[NSBundle mainBundle] infoDictionary][@"sourceURL"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sourceURL]];
}

- (IBAction)donate {
    self.products = nil;
    BOOL didRequest = [self.store requestProducts];
    if(didRequest)
    {
        [self.storeIndicator startAnimating];
        self.storeButton.enabled = NO;
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STORE_UNAVAILABLE_TITLE", nil)
                                    message:NSLocalizedString(@"STORE_UNAVAILABLE_MESSAGE", nil)
                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void) updateRadarDistancesSegmentedControl{
    [self.radarDistanceSegmentedControl removeAllSegments];
    
    NSNumber * radarDistance = [[NSUserDefaults standardUserDefaults] objectForKey:@"RadarDistance"];
    
    NSArray * distances = [[NSUserDefaults standardUserDefaults] arrayForKey:@"RadarDistances"];
    [distances enumerateObjectsUsingBlock:^(NSNumber * d, NSUInteger index, BOOL *stop) {
        [self.radarDistanceSegmentedControl insertSegmentWithTitle:[NSString stringWithFormat:@"%@ m",d]
                                                           atIndex:index animated:NO];
        if([radarDistance isEqualToNumber:d])
            self.radarDistanceSegmentedControl.selectedSegmentIndex = index;
    }];
}

- (IBAction)changeRadarDistance {
    NSArray * distances = [[NSUserDefaults standardUserDefaults] arrayForKey:@"RadarDistances"];
    NSNumber * d = distances[self.radarDistanceSegmentedControl.selectedSegmentIndex];
    [[NSUserDefaults standardUserDefaults] setObject:d forKey:@"RadarDistance"];
}

- (IBAction)updateStationsList {
    [self.model update];
}

/****************************************************************************/
#pragma mark Model updates

- (void) setModel:(VelibModel *)model
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:_model];
    _model = model;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelUpdated:) name:nil object:_model];
}

- (void) modelUpdated:(NSNotification*)note
{
    if([note.name isEqualToString:VelibModelNotifications.updateBegan])
    {
        [self.updateButton setTitle:NSLocalizedString(@"UPDATING : FETCHING", nil)];
        [self.updateIndicator startAnimating];
        self.updateButton.enabled = NO;
    }
    else if([note.name isEqualToString:VelibModelNotifications.updateGotNewData])
    {
        [self.updateButton setTitle:NSLocalizedString(@"UPDATING : PARSING", nil)];
    }
    else if([note.name isEqualToString:VelibModelNotifications.updateSucceeded])
    {
        [self.updateIndicator stopAnimating];
        self.updateButton.enabled = YES;
        BOOL dataChanged = [note.userInfo[VelibModelNotifications.keys.dataChanged] boolValue];
        NSArray * saveErrors = note.userInfo[VelibModelNotifications.keys.saveErrors];
        if(dataChanged)
        {
            [self.updateButton setTitle:NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil)];
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[Station entityName]];
            NSUInteger count = [self.model.moc countForFetchRequest:request error:NULL];
            NSString * title;
            NSString * message = [NSString stringWithFormat:NSLocalizedString(@"%d STATION COUNT OF TYPE %@", nil),
                                  count,
                                  self.model.name];
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
        else
            [self.updateButton setTitle:NSLocalizedString(@"UPDATING : NO NEW DATA", nil)];
    }
    else if([note.name isEqualToString:VelibModelNotifications.updateFailed])
    {
        [self.updateIndicator stopAnimating];
        self.updateButton.enabled = YES;
        [self.updateButton setTitle:NSLocalizedString(@"UPDATE_STATIONS_LIST_BUTTON", nil)];
        NSError * error = note.userInfo[VelibModelNotifications.keys.failureError];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UPDATING : FAILED",nil) 
                                   message:[error localizedDescription]
                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

/****************************************************************************/
#pragma mark Store updates

- (void) store:(Store*)store productsRequestDidFailWithError:(NSError*)error
{
    [self.storeIndicator stopAnimating];
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
        [storeSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ (%@)",product.localizedTitle,[priceFormatter stringFromNumber:product.price]]];
    }
    
    [storeSheet addButtonWithTitle:NSLocalizedString(@"STORE_SHEET_CANCEL", nil)];
    storeSheet.cancelButtonIndex = storeSheet.numberOfButtons-1;
    
    [storeSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==actionSheet.cancelButtonIndex)
    {
        [self actionSheetCancel:actionSheet];
        return;
    }
    SKProduct * product = self.products[buttonIndex];
    [self.store buy:product];
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [self.storeIndicator stopAnimating];
    self.storeButton.enabled = YES;
    self.products = nil;
}

- (void) store:(Store*)store purchaseSucceeded:(NSString*)productIdentifier
{
    NSLog(@"ok, cool %@", productIdentifier);
    [self.storeIndicator stopAnimating];
    self.storeButton.enabled = YES;
    self.products = nil;
}

- (void) store:(Store*)store purchaseCancelled:(NSString*)productIdentifier
{
    [self.storeIndicator stopAnimating];
    self.storeButton.enabled = YES;
    self.products = nil;
}

- (void) store:(Store*)store purchaseFailed:(NSString*)productIdentifier withError:(NSError*)error
{
    [self.storeIndicator stopAnimating];
    self.storeButton.enabled = YES;
    self.products = nil;
    [[[UIAlertView alloc] initWithTitle:error.localizedDescription
                                message:error.localizedFailureReason
                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
