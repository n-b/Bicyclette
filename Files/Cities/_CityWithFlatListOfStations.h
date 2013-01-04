//
//  _CityWithFlatListOfStations.m
//  Bicyclette
//
//  Created by Nicolas on 21/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_FuckCity.h"

// Common code for webservices returning a flat list of stations attributes.
@interface _CityWithFlatListOfStations : _FuckCity
- (void) fuckParseData:(NSData*)data;
@end

// To be implemented by subclasses
@protocol CityWithFlatListOfStations <FuckCity>
- (NSArray*) stationAttributesArraysFromData:(NSData*)data;
- (NSString*) stationNumberFromStationValues:(NSDictionary*)values;
@end

