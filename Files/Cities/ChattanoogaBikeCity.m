//
//  ChattanoogaBikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 21/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "ChattanoogaBikeCity.h"
#import "BicycletteCity.mogenerated.h"


@implementation ChattanoogaBikeCity

#pragma mark Annotations

//#pragma mark City Data Update

- (BOOL) hasRegions { return NO; }

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
