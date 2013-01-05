//
//  MiamiDecobikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInSubnodes.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

@interface MiamiDecobikeCity : _XMLCityWithStationDataInSubnodes <XMLCityWithStationDataInSubnodes>
@end

@implementation MiamiDecobikeCity

#pragma mark Annotations

- (NSString *)titleForStation:(Station *)station
{
    return [NSString stringWithFormat:@"%@ - %@",station.number, station.name];
}

#pragma mark City Data Update

- (NSString*) stationElementName
{
    return @"location";
}

- (NSDictionary*) KVCMapping
{
    return @{@"Id" : StationAttributes.number,
             @"Address" : StationAttributes.name,
             @"Latitude" : StationAttributes.latitude,
             @"Longitude": StationAttributes.longitude,
             @"Dockings": StationAttributes.status_free,
             @"Bikes": StationAttributes.status_available,
             };
}

@end
