//
//  PrefsVC.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 14/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "PrefsVC.h"

@interface PrefsVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak) IBOutlet UISegmentedControl *radarZonesSizeSegmentedControl;
@property (strong) IBOutletCollection(UITableViewCell) NSArray *cells;
@end

@implementation PrefsVC

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
- (IBAction)changeRadarZone {
}
- (IBAction)updateStationsList {
}

@end
