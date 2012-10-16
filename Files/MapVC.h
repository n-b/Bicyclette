//
//  MapVC.h
//  Bicyclette
//
//  Created by Nicolas on 04/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

@class BicycletteModel;
@class Station;

@interface MapVC : UIViewController 
@property BicycletteModel * model;

- (void) startUsingUserLocation;

- (void) zoomInStation:(Station*)station;

// Hook for faster animation
- (void) setAnnotationsHidden:(BOOL)hidden;

@end
