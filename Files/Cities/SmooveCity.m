//
//  SmooveCity.m
//  Bicyclette
//
//  Created by Nicolas on 02/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLAttributesCity.h"
#import "NSStringAdditions.h"

#pragma mark -

@interface SmooveCity : XMLAttributesCity
@end

@implementation SmooveCity

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return [[[station.name stringByTrimmingZeros] stringByDeletingPrefix:station.number] stringByTrimmingWhitespace]; }

- (NSDictionary *)KVCMapping
{
    return @{
             @"fr": @"status_free",
             @"id": @"number",
             @"na": @"name",
             @"av": @"status_available",
             @"la": @"latitude",
             @"to": @"status_total",
             @"lg": @"longitude"
             };
}

- (NSString *)stationElementName
{
    return @"si";
}

@end
