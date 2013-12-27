//
//  RootNavC.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/09/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "FanContainerViewController.h"

@class Station;
@class CitiesController;

@interface RootVC : FanContainerViewController

// Make outlets public, because they are set in MainWindow.nib
@property IBOutlet UIButton *infoButton;

@property (nonatomic) CitiesController * citiesController;

@end
