//
//  VelowayCity.m
//  Bicyclette
//
//  Created by Nicolas on 26/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "VelowayCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

@implementation VelowayCity

- (BOOL)hasRegions { return NO; }

- (NSString *)keyPathToStationsLists { return @"stand"; }

- (NSDictionary *)KVCMapping
{
    return @{@"id": StationAttributes.number,
             @"name": StationAttributes.name,
             @"wcom": StationAttributes.address,
             @"lat": StationAttributes.latitude,
             @"lng": StationAttributes.longitude,
             @"ab": StationAttributes.status_available,
             @"ac": StationAttributes.status_total,
             @"ap": StationAttributes.status_free
             };
}

- (NSString *) titleForStation:(Station *)station {
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
@end
