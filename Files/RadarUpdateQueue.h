//
//  RadarUpdateQueue.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 16/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@class BicycletteCity;

@interface RadarUpdateQueue : NSObject
- (id)initWithCity:(BicycletteCity*)city;

@property (nonatomic) CLLocation * referenceLocation;
@end
