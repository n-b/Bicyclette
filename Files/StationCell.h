//
//  StationCell.h
//  Bicyclette
//
//  Created by Nicolas on 10/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>


#define StationCellHeight 93
@class Station;
@class StationStatusView;
@interface StationCell : UITableViewCell 

// Outlets
@property (nonatomic, assign) IBOutlet UILabel * numberLabel;
@property (nonatomic, assign) IBOutlet UILabel * shortNameLabel;
@property (nonatomic, assign) IBOutlet UILabel * addressLabel;
@property (nonatomic, assign) IBOutlet UILabel * distanceLabel;

@property (nonatomic, assign) IBOutlet StationStatusView * statusView;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView * loadingIndicator;

@property (nonatomic, assign) IBOutlet UIButton * favoriteButton;
// Action
- (IBAction) switchFavorite;

// Data
@property (nonatomic, retain) Station * station;

@end
