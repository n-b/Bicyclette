//
//  BarcelonaCityBikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 26/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "FlatJSONListCity.h"
#import "BicycletteCity+Update.h"
#import "NSStringAdditions.h"

@interface BarcelonaCityBikeCity : FlatJSONListCity
@end

@implementation BarcelonaCityBikeCity

#pragma mark City Data Update

- (NSDictionary*) districts
{
    return @{@"26": @"10",
             @"106": @"6",
             @"193": @"4",
             @"238": @"9",
             @"101": @"5",
             @"5": @"1",
             @"1": @"2",
             @"276": @"7",
             @"93": @"3",
             @"275": @"8"
             };
}

- (RegionInfo *) regionInfoFromStation:(Station *)station values:(NSDictionary *)values patchs:(NSDictionary *)patchs requestURL:(NSString *)urlString
{
    NSString * districtCode = values[@"DisctrictCode"];
    NSString * patchedCode = self.districts[districtCode];
    if(patchedCode)
        districtCode = patchedCode;
    if([districtCode length])
        return [RegionInfo infoWithName:districtCode number:districtCode];
    else
        return nil;
}

#pragma mark Annotations

- (NSString *) titleForRegion:(Region*)region { return [NSString stringWithFormat:@"%@°",region.number]; }
- (NSString *) subtitleForRegion:(Region*)region { return @"dte."; }

- (NSDictionary *)KVCMapping
{
    return @{@"AddressGmapsLatitude": @"latitude",
             @"StationAvailableBikes": @"status_available",
             @"AddressStreet1": @"name",
             @"StationID": @"number",
             @"AddressGmapsLongitude": @"longitude",
             @"StationFreeSlot": @"status_free"
             };    
}

@end
