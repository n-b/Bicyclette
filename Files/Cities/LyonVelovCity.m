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

- (NSString*) titleForRegion:(Region*)region { return [NSString stringWithFormat:@"%@°",region.number]; }
- (NSString*) subtitleForRegion:(Region*)region { return @"arr."; }

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

- (RegionInfo*) regionInfoFromStation:(Station*)station values:(NSDictionary*)values patchs:(NSDictionary*)patchs requestURL:(NSString*)urlString
{
    NSString * regionNumber = [urlString substringFromIndex:[urlString length]-1];
    return [RegionInfo infoWithName:regionNumber number:regionNumber];
}

@end
