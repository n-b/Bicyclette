//
//  ChattanoogaBikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 21/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_CityWithJSONFlatListOfStations.h"
#import "BicycletteCity.mogenerated.h"

@interface ChattanoogaBikeCity : _CityWithJSONFlatListOfStations <CityWithJSONFlatListOfStations>
@end

@implementation ChattanoogaBikeCity

#pragma mark City Data Update

- (NSString*) stationNumberFromStationValues:(NSDictionary*)values
{
    return values[@"id"];
}

- (NSString*) keyPathToStationsLists
{
    return @"stationBeanList";
}

- (NSDictionary*) KVCMapping
{
    return @{@"id" : StationAttributes.number,
    @"landMark" : StationAttributes.name,
    @"latitude" : StationAttributes.latitude,
    @"longitude": StationAttributes.longitude,
    @"stAddress1": StationAttributes.address,
    @"availableDocks": StationAttributes.status_free,
    @"availableBikes": StationAttributes.status_available,
    };
}

@end
