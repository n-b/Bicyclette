//
//  RegionCell.h
//  Bicyclette
//
//  Created by Nicolas on 01/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>


#define RegionCellHeight 62
@class Region;
@interface RegionCell : UITableViewCell 

// Data
@property (nonatomic, strong) Region * region;

@end
