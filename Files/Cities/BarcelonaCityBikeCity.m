//
//  BarcelonaCityBikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 26/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_CityWithJSONFlatListOfStations.h"
#import "BicycletteCity+Update.h"
#import "NSStringAdditions.h"

@interface BarcelonaCityBikeCity : _CityWithJSONFlatListOfStations
@end

@implementation BarcelonaCityBikeCity

#pragma mark City Data Update

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
