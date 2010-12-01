//
//  RegionCell.h
//  Bicyclette
//
//  Created by Nicolas on 01/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Region;
@interface RegionCell : UITableViewCell 

// Outlets
@property (nonatomic, assign) IBOutlet UILabel * nameLabel;
@property (nonatomic, assign) IBOutlet UILabel * countLabel;

// Data
@property (nonatomic, retain) Region * region;

@end
