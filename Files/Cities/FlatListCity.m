//
//  FlatListCity.m
//  Bicyclette
//
//  Created by Nicolas on 21/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "FlatListCity.h"

// Allow me to call methods of subclasses
@interface FlatListCity (CityWithFlatListOfStations) <CityWithFlatListOfStations>
@end

@implementation FlatListCity

- (void) parseData:(NSData*)data
{
    id attributesArray = [self stationAttributesArraysFromData:data];
    
    for (NSDictionary * attributeDict in attributesArray) {
        [self insertStationWithAttributes:attributeDict];
    }
}


@end
