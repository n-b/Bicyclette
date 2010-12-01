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
@property (nonatomic, assign) IBOutlet UITableView * tableView;
@property (nonatomic, retain) NSFetchedResultsController *frc;
@end


@interface FavoriteStationsVC : StationsVC
@end

@interface AllStationsVC : StationsVC
@end

@class Region;

@interface RegionStationsVC : StationsVC
@property (nonatomic, readonly, retain) Region * region;
+ (id) stationsVCWithRegion:(Region*)region;
- (id) initWithRegion:(Region*)region;
@end
