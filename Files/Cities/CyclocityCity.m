//
//  CyclocityCity.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CyclocityCity.h"
#import "NSStringAdditions.h"
#import "_StationParse.h"

@implementation CyclocityCity
#pragma mark Annotations

- (NSString*) titleForStation:(Station*)station
{
    NSString * title = station.name;
    title = [title stringByTrimmingZeros];
    title = [title stringByDeletingPrefix:station.number];
    title = [title stringByTrimmingWhitespace];
    title = [title stringByDeletingPrefix:@"-"];
    title = [title stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    title = [title stringByTrimmingWhitespace];
    title = [title capitalizedStringWithCurrentLocale];
    return title;
}

- (NSDictionary *)KVCMapping
{
    return @{
             @"fullAddress": @"fullAddress",
             @"ticket": @"status_ticket",
             @"total": @"status_total",
             @"lat": @"latitude",
             @"address": @"address",
             @"open": @"open",
             @"number": @"number",
             @"available": @"status_available",
             @"lng": @"longitude",
             @"free": @"status_free",
             @"name": @"name",
             @"bonus": @"bonus"
             };
}

- (Class)stationStatusParsingClass
{
    return [XMLSubnodesStationParse class];
}

@end

