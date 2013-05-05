//
//  BCycleCity.m
//  Bicyclette
//
//  Created by Nicolas on 20/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "FlatJSONListCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

@interface BCycleCity : FlatJSONListCity
@end

@implementation BCycleCity

#pragma mark - override

- (NSArray *) updateURLStrings { return @[@"http://api.bcycle.com/services/mobile.svc/ListKiosks"]; }

- (NSArray*) stationAttributesArraysFromData:(NSData*)data
{
    return [super stationAttributesArraysFromData:data];
}

- (void) insertStationWithAttributes:(NSDictionary*)stationAttributes
{
    NSString * cityName = [[stationAttributes[@"Address.City"] lowercaseString] stringByTrimmingWhitespace];
    if([self.serviceInfo[@"bcycle_city_names"] containsObject:cityName])
        [super insertStationWithAttributes:stationAttributes];
}

- (NSDictionary *)KVCMapping
{
    return @{
             @"Id": @"number",
             @"Location.Longitude": @"longitude",
             @"Location.Latitude": @"latitude",
             @"DocksAvailable": @"status_free",
             @"Address.Street": @"address",
             @"TotalDocks": @"status_total",
             @"Name": @"name",
             @"BikesAvailable": @"status_available"
             };
}

- (NSString *)keyPathToStationsLists
{
    return @"d.list";
}

@end
