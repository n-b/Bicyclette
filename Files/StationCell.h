//
//  StationCell.h
//  Bicyclette
//
//  Created by Nicolas on 10/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>


#define StationCellHeight 100
@class Station;
@class StationStatusView;
@interface StationCell : UITableViewCell 

// Outlets
@property (nonatomic, weak) IBOutlet UILabel * shortNameLabel;
@property (nonatomic, weak) IBOutlet UILabel * availableCountLabel;
@property (nonatomic, weak) IBOutlet UILabel * freeCountLabel;

@property (nonatomic, weak) IBOutlet StationStatusView * statusView;
@property (nonatomic, weak) IBOutlet UIView * loadingIndicator;

@property (nonatomic, weak) IBOutlet UIButton * favoriteButton;
// Action
- (IBAction) switchFavorite;

// Data
@property (nonatomic, strong) Station * station;

@end
