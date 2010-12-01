//
//  StationsVC.h
//  Bicyclette
//
//  Created by Nicolas on 10/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StationsVC : UIViewController

@property (nonatomic, assign) IBOutlet UITableView * tableView;

@end


@interface FavoriteStationsVC : StationsVC

@end

@interface AllStationsVC : StationsVC

@end
