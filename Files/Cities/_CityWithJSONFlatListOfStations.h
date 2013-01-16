//
//  _CityWithJSONFlatListOfStations.h
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "_CityWithFlatListOfStations.h"

// JSON
@interface _CityWithJSONFlatListOfStations : _CityWithFlatListOfStations
- (NSArray*) stationAttributesArraysFromData:(NSData*)data; // basic JSON deserialize
- (NSString*) keyPathToStationsLists; // override if necessary
@end

