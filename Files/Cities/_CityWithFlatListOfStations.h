//
//  _CityWithFlatListOfStations.m
//  Bicyclette
//
//  Created by Nicolas on 21/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"

// Common code for webservices returning a flat list of stations attributes.
@interface _CityWithFlatListOfStations : _BicycletteCity

- (BOOL) hasRegions; //NO

- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations;

@end

// To be implemented by subclasses
@protocol CityWithFlatListOfStations <BicycletteCity>
- (NSArray*) stationAttributesArraysFromData:(NSData*)data;
- (NSDictionary*) KVCMapping;
@end

