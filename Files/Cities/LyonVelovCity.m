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
    NSArray * zips = [self.serviceInfo[@"regions"] allKeys];
    
    NSMutableArray * urlStrings = [NSMutableArray new];
    for (NSString * zip in zips) {
        [urlStrings addObject:[baseURL stringByAppendingString:zip]];
    }
    return urlStrings;
}

- (RegionInfo*) regionInfoFromStation:(Station*)station values:(NSDictionary*)values patchs:(NSDictionary*)patchs requestURL:(NSString*)urlString
{
    NSString * zip = [urlString stringByDeletingPrefix:self.serviceInfo[@"update_url"]];
    NSDictionary * zips = self.serviceInfo[@"regions"];
    NSString * name = zips[zip];
    return [RegionInfo infoWithName:name number:name];
}

@end
