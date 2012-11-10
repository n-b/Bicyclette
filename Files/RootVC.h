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

// Autorotation Management for iOS 6
@interface RootVC : FanContainerViewController

@property (nonatomic) CitiesController * citiesController;

@end
