//
//  _CityWithFlatListOfStations.m
//  Bicyclette
//
//  Created by Nicolas on 21/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"

@interface _CityWithFlatListOfStations : _BicycletteCity
- (void) parseData:(NSData*)data;
@end

// To be implemented by subclasses
@protocol CityWithFlatListOfStations <BicycletteCity>
- (NSArray*) stationAttributesArraysFromData:(NSData*)data;
- (NSString*) stationNumberFromStationValues:(NSDictionary*)values;
@end

