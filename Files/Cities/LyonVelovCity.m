//
//  LyonVelovCity.m
//  Bicyclette
//
//  Created by Nicolas on 13/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_CityWithJSONFlatListOfStations.h"

#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"
#import "CollectionsAdditions.h"
#import "NSObject+KVCMapping.h"
#import "_StationParse.h"

@interface LyonVelovCity : _CityWithJSONFlatListOfStations <CityWithJSONFlatListOfStations>
@end

@implementation LyonVelovCity

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

- (NSString*) titleForRegion:(Region*)region { return [NSString stringWithFormat:@"%@°",region.number]; }
- (NSString*) subtitleForRegion:(Region*)region { return @"arr."; }

#pragma mark Stations Individual Data Updates

- (Class) stationStatusParsingClass { return [XMLSubnodesStationParse class]; }

#pragma mark City Data Update

- (NSArray*) updateURLStrings
{
    NSArray * zips = @[@"69381",
                       @"69382",
                       @"69383",
                       @"69384",
                       @"69385",
                       @"69386",
                       @"69387",
                       @"69388",
                       @"69389"];
    
    NSMutableArray * urlStrings = [NSMutableArray new];
    NSString * baseURL = self.serviceInfo[@"update_url"];
    for (NSString * zip in zips) {
        [urlStrings addObject:[baseURL stringByAppendingString:zip]];
    }
    return urlStrings;
}

- (NSString*) keyPathToStationsLists
{
    return @"markers";
}

- (NSDictionary*) KVCMapping
{
    return @{
             @"infoStation": StationAttributes.address,
             @"nomStation": StationAttributes.name,
             @"numStation": StationAttributes.number,
             @"x": StationAttributes.latitude, // yes. x,y for lat,long. (not even x,y for long,lat !)
             @"y": StationAttributes.longitude,

             @"available" : StationAttributes.status_available,
             @"free" : StationAttributes.status_free,
             @"ticket": StationAttributes.status_ticket,
             @"total" : StationAttributes.status_total
             };
}

- (RegionInfo*) regionInfoFromStation:(Station*)station values:(NSDictionary*)values patchs:(NSDictionary*)patchs requestURL:(NSString*)urlString
{
    NSString * regionNumber = [urlString substringFromIndex:[urlString length]-1];
    return [RegionInfo infoWithName:regionNumber number:regionNumber];
}

@end
