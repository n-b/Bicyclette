//
//  NextBikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 24/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLAttributesCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

@interface NextBikeCity : XMLAttributesCity
@end

@implementation NextBikeCity

#pragma mark City Data Update

- (NSString*) baseURL
{
    return @"http://www.nextbike.de/maps/nextbike-official.xml?city=";
}

- (NSArray *) updateURLStrings
{
    if( self.serviceInfo[@"regions"] )
    {
        NSDictionary * regions = self.serviceInfo[@"regions"];
        NSMutableArray * result = [NSMutableArray new];
        for (NSString * regionID in regions) {
            [result addObject:[self.baseURL stringByAppendingString:regionID]];
        }
        return result;
    }
    else if( self.serviceInfo[@"region"]) {
        return @[[self.baseURL stringByAppendingString:self.serviceInfo[@"region"]]];
    } else {
        return nil;
    }
}

- (NSDictionary *)KVCMapping
{
    return @{
             @"lng": @"longitude",
             @"lat": @"latitude",
             @"uid": @"number",
             @"name": @"name",
             @"bikes": @"status_available"
             };
}

- (NSString *)stationElementName
{
    return @"place";
}

@end
