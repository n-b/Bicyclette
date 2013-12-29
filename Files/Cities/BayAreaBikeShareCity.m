//
//  BayAreaBikeShareCity.m
//  Bicyclette
//
//  Created by Nicolas on 29/12/2013.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "FlatJSONListCity.h"

@interface BayAreaBikeShareCity : FlatJSONListCity
@end

@implementation BayAreaBikeShareCity

// Mapping
- (NSArray *)updateURLStrings
{
    return @[@"http://www.bayareabikeshare.com/stations/json/"];
}
- (NSString*) keyPathToStationsLists
{
    return @"stationBeanList";
}
- (NSDictionary *)KVCMapping
{
    return @{@"stAddress1": @"address",
             @"latitude": @"latitude",
             @"availableDocks": @"status_free",
             @"stationName": @"name",
             @"id": @"number",
             @"longitude": @"longitude",
             @"availableBikes": @"status_available"
             };
}

// Per-City filtering
- (void) insertStationWithAttributes:(NSDictionary*)stationAttributes
{
    if([self.serviceInfo[@"bayarea_city"] isEqualToString:stationAttributes[@"city"]]) {
        [super insertStationWithAttributes:stationAttributes];
    }
}

@end
