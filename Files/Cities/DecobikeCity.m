//
//  DecobikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLSubnodesCity.h"
#import "NSStringAdditions.h"

@interface DecobikeCity : XMLSubnodesCity
@end

@implementation DecobikeCity

#pragma mark Annotations

- (NSString *)titleForStation:(Station *)station
{
    return [NSString stringWithFormat:@"%@ - %@",station.number, station.name];
}

- (NSDictionary *)KVCMapping
{
    return @{
             @"Latitude": @"latitude",
             @"Address": @"name",
             @"Bikes": @"status_available",
             @"Longitude": @"longitude",
             @"Dockings": @"status_free",
             @"Id": @"number"
             };
    
}

- (NSString *)stationElementName
{
    return @"location";
}

@end
