//
//  VelowayCity.m
//  Bicyclette
//
//  Created by Nicolas on 26/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "FlatJSONListCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

@interface VelowayCity : FlatJSONListCity
@end

@implementation VelowayCity

#pragma mark Annotations

- (NSString*) titleForStation:(Station *)station {
    NSString * title;
    if([station.address length])
        title = station.address;
    else
        title = station.name;
    title = [title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    title = [title stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    title = [title capitalizedStringWithCurrentLocale];
    return title;
}

- (NSDictionary *)KVCMapping
{
    return @{@"ac": @"status_total",
             @"ap": @"status_free",
             @"id": @"number",
             @"wcom": @"address",
             @"lat": @"latitude",
             @"lng": @"longitude",
             @"name": @"name",
             @"ab": @"status_available"
             };
}

- (NSString *)keyPathToStationsLists
{
    return @"stand";
}

@end
