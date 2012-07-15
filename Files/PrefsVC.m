//
//  PrefsVC.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 14/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "PrefsVC.h"

@interface PrefsVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak) IBOutlet UISegmentedControl *radarDistanceSegmentedControl;
@property (strong) IBOutletCollection(UITableViewCell) NSArray *cells;
@end

@implementation PrefsVC

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateRadarDistancesSegmentedControl];
}

/****************************************************************************/
#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.cells objectAtIndex:indexPath.row];
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
    NSString * designURL = [NSString stringWithFormat:@"http://%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"designURL"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:designURL]];    
}

- (IBAction)openSourcePage {
    NSString * sourceURL = [NSString stringWithFormat:@"http://%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"sourceURL"]];
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
    NSNumber * d = [distances objectAtIndex:self.radarDistanceSegmentedControl.selectedSegmentIndex];
    [[NSUserDefaults standardUserDefaults] setObject:d forKey:@"RadarDistance"];
}

- (IBAction)updateStationsList {
}

@end
