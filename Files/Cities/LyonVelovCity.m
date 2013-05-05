//
//  LyonVelovCity.m
//  Bicyclette
//
//  Created by Nicolas on 13/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "NSStringAdditions.h"
#import "CollectionsAdditions.h"
#import "JCDecauxCity.h"

@interface LyonVelovCity : JCDecauxCity
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

- (NSDictionary*) zips
{
    return @{@"01": @"1",
             @"02": @"2",
             @"03": @"3",
             @"04": @"4",
             @"05": @"5",
             @"06": @"6",
             @"07": @"7",
             @"08": @"8",
             @"09": @"9",

             @"10": @"Villeurbanne",

             @"11": @"4",			 // 2 stations in Caluire-et-Cuire -> group with 4th
             @"12": @"Villeurbanne", // 2 stations in Vaulx-en-Velin -> group with Villeurbanne
             };
}

- (RegionInfo*) regionInfoFromStation:(Station*)station values:(NSDictionary*)values patchs:(NSDictionary*)patchs requestURL:(NSString*)urlString
{
    NSString * number = station.number;
    while([number length]<5) {
        number = [@"0" stringByAppendingString:number];
    }

    NSString * name = self.zips[[number substringToIndex:2]];
    return [RegionInfo infoWithName:name number:name];
}


@end
