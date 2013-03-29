//
//  MelbourneBikeShareCity.m
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

- (NSDictionary*) KVCMapping
{
    return @{
             @"Address.Street": @"address",
             @"Location.Latitude": @"latitude",
             @"Location.Longitude": @"longitude",

             @"Name": @"name",
             @"Id": @"number",
             @"BikesAvailable": @"status_available",
             @"DocksAvailable": @"status_free",
             @"TotalDocks": @"status_total",
             };
}

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

@end
