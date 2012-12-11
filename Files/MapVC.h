//
//  MapVC.h
//  Bicyclette
//
//  Created by Nicolas on 04/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "CitiesController.h"

@class BicycletteCity;
@class Station;

@interface MapVC : UIViewController  <CitiesControllerDelegate>

@property CitiesController * controller;

@end
