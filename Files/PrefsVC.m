//
//  PrefsVC.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 14/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "PrefsVC.h"
#import "VelibModel.h"
#import "Station.h"

@interface PrefsVC () <UITableViewDataSource, UITableViewDelegate>
@property (strong) IBOutletCollection(UITableViewCell) NSArray *cells;

@property (weak) IBOutlet UISegmentedControl *radarDistanceSegmentedControl;

@property (weak) IBOutlet UIActivityIndicatorView *updateIndicator;
@property (weak) IBOutlet UIBarButtonItem *updateButton;
@property (weak) IBOutlet UILabel *updateLabel;
@end

@implementation PrefsVC

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateRadarDistancesSegmentedControl];
    if(![self.updateIndicator isAnimating])
        self.updateLabel.text = @"";
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
        self.updateLabel.text = NSLocalizedString(@"UPDATING : FETCHING", nil);
        [self.updateIndicator startAnimating];
        self.updateButton.enabled = NO;
    }
    else if([note.name isEqualToString:VelibModelNotifications.updateGotNewData])
    {
        self.updateLabel.text = NSLocalizedString(@"UPDATING : PARSING", nil);
    }
    else if([note.name isEqualToString:VelibModelNotifications.updateSucceeded])
    {
        [self.updateIndicator stopAnimating];
        self.updateButton.enabled = YES;
        BOOL dataChanged = [note.userInfo[VelibModelNotifications.keys.dataChanged] boolValue];
        NSArray * saveErrors = note.userInfo[VelibModelNotifications.keys.saveErrors];
        if(dataChanged)
        {
            self.updateLabel.text = @"";
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
            self.updateLabel.text = NSLocalizedString(@"UPDATING : NO NEW DATA", nil);
    }
    else if([note.name isEqualToString:VelibModelNotifications.updateFailed])
    {
        [self.updateIndicator stopAnimating];
        self.updateButton.enabled = YES;
        self.updateLabel.text = @"";
        NSError * error = note.userInfo[VelibModelNotifications.keys.failureError];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UPDATING : FAILED",nil) 
                                   message:[error localizedDescription]
                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

@end
