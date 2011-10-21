//
//  StationsVC.h
//  Bicyclette
//
//  Created by Nicolas on 10/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface StationsVC : UIViewController
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UILabel * noFavoriteLabel;
@end


@interface FavoriteStationsVC : StationsVC
@end

@class Region;

@interface RegionStationsVC : StationsVC
@property (nonatomic, readonly, strong) Region * region;
+ (id) stationsVCWithRegion:(Region*)region;
- (id) initWithRegion:(Region*)region;
@end
