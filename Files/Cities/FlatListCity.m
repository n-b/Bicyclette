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
    
    // Loop on attribute dictionaries
    for (NSDictionary * attributeDict in attributesArray) {

        // If a station dictionary attribute is a dictionary, flatten its keys in the station dictionary
        NSMutableDictionary * flattenAttributes = [attributeDict mutableCopy];
        for (NSString * key in attributeDict) {
            NSDictionary * attribute = attributeDict[key];
            if([attribute isKindOfClass:[NSDictionary class]])
            {
                for (id key2 in attribute) {
                    flattenAttributes[[NSString stringWithFormat:@"%@.%@",key, key2]] = attribute[key2];
                }
            }
        }

        // Go
        [self insertStationWithAttributes:flattenAttributes];
    }
}


@end
