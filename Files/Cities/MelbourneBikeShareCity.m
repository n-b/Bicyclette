//
//  MelbourneBikeShareCity.m
//  Bicyclette
//
//  Created by Nicolas on 20/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "FlatJSONListCity.h"
#import "BicycletteCity.mogenerated.h"

@interface MelbourneBikeShareCity : FlatJSONListCity
@end

@implementation MelbourneBikeShareCity

#pragma mark - override

- (NSArray *)updateURLStrings
{
    return @[@"http://www.melbournebikeshare.com.au/stationmap/data"];
}

- (NSArray*) stationAttributesArraysFromData:(NSData*)data
{
    // The JSON is invalid. Great.
    NSMutableString * str = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [str replaceOccurrencesOfString:@"\\x26" withString:@"&" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\\'" withString:@"'" options:0 range:NSMakeRange(0, [str length])];
    
    return [super stationAttributesArraysFromData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSDictionary *)KVCMapping
{
    return @{@"id": @"number",
             @"lat": @"latitude",
             @"long": @"longitude",
             @"name": @"name",
             @"nbEmptyDocks": @"status_free",
             @"nbBikes": @"status_available"
             };
}

@end
