//
//  BIXICity.m
//  Bicyclette
//
//  Created by Nicolas on 05/03/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLSubnodesCity.h"

@interface BIXICity : XMLSubnodesCity
@end

@implementation BIXICity

- (NSDictionary *)KVCMapping
{
    return @{@"id": @"number",
             @"lat": @"latitude",
             @"long": @"longitude",
             @"name": @"name",
             @"nbEmptyDocks": @"status_free",
             @"nbBikes": @"status_available"
             };
}

- (NSString *)stationElementName
{
    return @"station";
}

@end
