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
@property (nonatomic, assign) IBOutlet UILabel * shortNameLabel;
@property (nonatomic, assign) IBOutlet UILabel * availableCountLabel;
@property (nonatomic, assign) IBOutlet UILabel * freeCountLabel;

@property (nonatomic, assign) IBOutlet StationStatusView * statusView;
@property (nonatomic, assign) IBOutlet UIView * loadingIndicator;

@property (nonatomic, assign) IBOutlet UIButton * favoriteButton;
// Action
- (IBAction) switchFavorite;

// Data
@property (nonatomic, retain) Station * station;

@end
