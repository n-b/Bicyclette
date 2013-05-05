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

- (NSArray *)updateURLStrings
{
    return @[@"https://www.bicing.cat/localizaciones/getJsonObject.php"];
}

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

- (NSArray *)stationAttributesArraysFromData:(NSData *)data
{
    // For some reason, Bicing has invented the JSON-in-JSON format.
    NSError* error;
    NSArray * rawJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (rawJSON==nil ||
        ![rawJSON isKindOfClass:[NSArray class]] ||
        ![rawJSON count]>1 ||
        ![[rawJSON objectAtIndex:1] isKindOfClass:[NSDictionary class]] ||
        ![[[rawJSON objectAtIndex:1] objectForKey:@"data"] isKindOfClass:[NSString class]]
        ) {
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteLogParsingDetails"])
            DebugLog(@"Invalid Data : %@,%@",error, data);
        return nil;
    }
    NSString * json = [[rawJSON objectAtIndex:1] objectForKey:@"data"];
    NSData * jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    return [super stationAttributesArraysFromData:jsonData];
}

@end
