//
//  WienCitybikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInSubnodes.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

@interface WienCitybikeCity : _XMLCityWithStationDataInSubnodes <XMLCityWithStationDataInSubnodes>
@end

@implementation WienCitybikeCity

#pragma mark City Data Update

- (NSString*) stationElementName
{
    return @"station";
}

- (NSDictionary*) KVCMapping
{
    return @{@"id" : StationAttributes.number,
             @"name" : StationAttributes.name,
             @"description" : StationAttributes.address,
             @"latitude" : StationAttributes.latitude,
             @"longitude": StationAttributes.longitude,
             @"boxes": StationAttributes.status_total,
             @"free_bikes": StationAttributes.status_free,
             @"free_boxes": StationAttributes.status_available,
             };
}

@end
