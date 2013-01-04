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
    if( ! [self hasRegions] )
    {
        return [super updateURLStrings];
    }
    else
    {
        NSString * baseURL = self.serviceInfo[@"update_url"];
        NSDictionary * regions = self.serviceInfo[@"regions"];
        NSMutableArray * result = [NSMutableArray new];
        for (NSString * regionID in regions) {
            [result addObject:[baseURL stringByAppendingString:regionID]];
        }
        return result;
    }
}

- (NSString*) stationElementName
{
    return @"place";
}

- (NSString*) stationNumberFromStationValues:(NSDictionary*)values
{
    return values[@"uid"];
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

#pragma mark Regions

- (BOOL) hasRegions
{
    return self.serviceInfo[@"regions"]!=nil;
}

- (RegionInfo*) regionInfoFromStation:(Station*)station values:(NSDictionary*)values patchs:(NSDictionary*)patchs requestURL:(NSString*)urlString
{
    if([self hasRegions])
    {
        NSString * number = [urlString stringByDeletingPrefix:self.serviceInfo[@"update_url"]];
        return [RegionInfo infoWithName:number
                                 number:self.serviceInfo[@"regions"][number]];
    }
    else
    {
        return [RegionInfo infoWithName:@"anonymousregion" number:@"anonymousregion"];
    }
}


@end
