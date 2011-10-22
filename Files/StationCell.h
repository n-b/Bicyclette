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

// Action
- (IBAction) switchFavorite;

// Data
@property (nonatomic, strong) Station * station;

@end
