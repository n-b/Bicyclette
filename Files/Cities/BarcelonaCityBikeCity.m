//
//  BarcelonaCityBikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 26/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_CityWithJSONFlatListOfStations.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

@interface BarcelonaCityBikeCity : _CityWithJSONFlatListOfStations <CityWithJSONFlatListOfStations>
@end

@implementation BarcelonaCityBikeCity

#pragma mark City Data Update

- (NSDictionary*) KVCMapping
{
    return @{@"StationID": StationAttributes.number,
             @"AddressStreet1": StationAttributes.name,
             @"AddressGmapsLatitude": StationAttributes.latitude,
             @"AddressGmapsLongitude": StationAttributes.longitude,
             @"StationAvailableBikes": StationAttributes.status_available,
             @"StationFreeSlot": StationAttributes.status_free
             };
}

- (RegionInfo *) regionInfoFromStation:(Station *)station values:(NSDictionary *)values patchs:(NSDictionary *)patchs requestURL:(NSString *)urlString
{
    NSString * districtCode = values[@"DisctrictCode"];
    NSString * patchedCode = self.serviceInfo[@"districts_patchs"][districtCode];
    if(patchedCode)
        districtCode = patchedCode;
    return [RegionInfo infoWithName:districtCode number:districtCode];
}

#pragma mark Annotations

- (NSString *) titleForRegion:(Region*)region { return [NSString stringWithFormat:@"%@°",region.number]; }
- (NSString *) subtitleForRegion:(Region*)region { return @"dte."; }

@end
