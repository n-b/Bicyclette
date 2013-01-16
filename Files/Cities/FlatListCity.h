//
//  FlatListCity.h
//  Bicyclette
//
//  Created by Nicolas on 21/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity+Update.h"

@interface FlatListCity : BicycletteCity
- (void) parseData:(NSData*)data;
@end

// To be implemented by subclasses
@protocol CityWithFlatListOfStations <BicycletteCity>
- (NSArray*) stationAttributesArraysFromData:(NSData*)data;
@end

