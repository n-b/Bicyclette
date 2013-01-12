//
//  _CityWithFlatListOfStations.m
//  Bicyclette
//
//  Created by Nicolas on 21/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_CityWithFlatListOfStations.h"

// Allow me to call methods of subclasses
@interface _CityWithFlatListOfStations (CityWithFlatListOfStations) <CityWithFlatListOfStations>
@end

@implementation _CityWithFlatListOfStations

- (void) parseData:(NSData*)data
{
    id attributesArray = [self stationAttributesArraysFromData:data];
    
    for (NSDictionary * attributeDict in attributesArray) {
        [self insertStationWithAttributes:attributeDict];
    }
}


@end
