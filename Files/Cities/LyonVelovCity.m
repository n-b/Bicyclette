//
//  LyonVelovCity.m
//  Bicyclette
//
//  Created by Nicolas on 13/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "FlatJSONListCity.h"
#import "NSStringAdditions.h"
#import "CollectionsAdditions.h"
#import "_StationParse.h"

@interface LyonVelovCity : FlatJSONListCity
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

- (NSString*) titleForRegion:(Region*)region {
    if([region.name length]==1) {
        return [NSString stringWithFormat:@"%@°",region.name];
    } else if([region.name length]) {
        return [region.name substringToIndex:1];
    } else {
        return @"";
    }
}

- (NSString*) subtitleForRegion:(Region*)region {
    if([region.name length]==1) {
        return @"arr.";
    } else if([region.name length]) {
        return [region.name substringFromIndex:1];
    } else {
        return @"";
    }
}

#pragma mark City Data Update

- (NSArray*) updateURLStrings
{
    NSString * baseURL = self.serviceInfo[@"update_url"];
    
    NSMutableArray * urlStrings = [NSMutableArray new];
    for (NSString * zip in self.zips) {
        [urlStrings addObject:[baseURL stringByAppendingString:zip]];
    }
    return urlStrings;
}

- (NSDictionary*) zips
{
    return @{@"69381": @"1",
             @"69382": @"2",
             @"69383": @"3",
             @"69384": @"4",
             @"69385": @"5",
             @"69386": @"6",
             @"69387": @"7",
             @"69388": @"8",
             @"69389": @"9",
             @"69256": @"Villeurbanne",

             @"69266": @"Villeurbanne",
             @"69034": @"4",
             };
}

- (RegionInfo*) regionInfoFromStation:(Station*)station values:(NSDictionary*)values patchs:(NSDictionary*)patchs requestURL:(NSString*)urlString
{
    NSString * zip = [urlString stringByDeletingPrefix:self.serviceInfo[@"update_url"]];
    NSString * name = self.zips[zip];
    return [RegionInfo infoWithName:name number:name];
}

- (NSDictionary *)KVCMapping
{
    return @{@"x": @"latitude",
             @"y": @"longitude",
             @"numStation": @"number",
             @"nomStation": @"name",
             @"infoStation": @"address",
             @"ticket": @"status_ticket",
             @"available": @"status_available",
             @"total": @"status_total",
             @"free": @"status_free",
             };
}

- (NSString *)keyPathToStationsLists
{
    return @"markers";
}

- (Class)stationStatusParsingClass
{
    return [XMLSubnodesStationParse class];
}

@end
