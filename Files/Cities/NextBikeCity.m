//
//  NextBikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 24/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInAttributes.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

@interface NextBikeCity : _XMLCityWithStationDataInAttributes <XMLCityWithStationDataInAttributes>
@end

@implementation NextBikeCity

#pragma mark City Data Update

- (NSArray *) updateURLStrings
{
    if( self.serviceInfo[@"regions"] )
    {
        NSString * baseURL = self.serviceInfo[@"update_url"];
        NSDictionary * regions = self.serviceInfo[@"regions"];
        NSMutableArray * result = [NSMutableArray new];
        for (NSString * regionID in regions) {
            [result addObject:[baseURL stringByAppendingString:regionID]];
        }
        return result;
    }
    else
    {
        return [super updateURLStrings];
    }
}

- (NSString*) stationElementName
{
    return @"place";
}

- (NSDictionary*) KVCMapping
{
    return @{@"uid" : StationAttributes.number,
             @"name" : StationAttributes.name,
             @"lat" : StationAttributes.latitude,
             @"lng": StationAttributes.longitude,
             @"bikes": StationAttributes.status_available
             };
}

@end
