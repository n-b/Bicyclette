//
//  _CityWithFlatListOfStations.m
//  Bicyclette
//
//  Created by Nicolas on 21/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_CityWithFlatListOfStations.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"

// Allow me to call methods of subclasses
@interface _CityWithFlatListOfStations (CityWithFlatListOfStations) <CityWithFlatListOfStations>
@end

@implementation _CityWithFlatListOfStations

- (void) fuckParseData:(NSData*)data
{
    id attributesArray = [self stationAttributesArraysFromData:data];
    
    for (NSDictionary * attributeDict in attributesArray) {
        NSString * stationNumber = [self stationNumberFromStationValues:attributeDict];
        [self setValues:attributeDict toStationWithNumber:stationNumber];
    }
}


@end
