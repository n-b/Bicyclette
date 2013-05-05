//
//  LaRochelleYeloCity.m
//  Bicyclette
//
//  Created by Nicolas on 18/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "FlatListCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

@interface LaRochelleYeloCity : FlatListCity <CityWithFlatListOfStations>
@end

@implementation LaRochelleYeloCity

#pragma mark City Data Update

- (NSArray*) stationAttributesArraysFromData:(NSData*)data;
{
    NSString * string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSScanner * scanner = [NSScanner scannerWithString:string];
    NSString * jsonText = nil;
    [scanner scanUpToString:@"<script type=\"text/javascript\">var markers = [{" intoString:nil];
    [scanner scanString:@"<script type=\"text/javascript\">var markers = [{" intoString:nil];
    [scanner scanUpToString:@"}]</script>" intoString:&jsonText];
    if([jsonText length] == 0)
        return nil;

    NSMutableArray * attributesArray = [NSMutableArray new];
    for (NSString * stationText in [jsonText componentsSeparatedByString:@"},{"]) {
        NSMutableDictionary * attributes = [NSMutableDictionary new];
        for (NSString * attr in [stationText componentsSeparatedByString:@","]) {
            NSArray * keyAndValue = [attr componentsSeparatedByString:@":"];
            if([keyAndValue count]==2)
            {
                attributes[[keyAndValue[0] stringByTrimmingWhitespace]] = [[keyAndValue[1] stringByTrimmingWhitespace] stringByTrimmingQuotes];
            }
        }
        [attributesArray addObject:attributes];
    }
    
    return attributesArray;
}

- (NSDictionary *)KVCMapping
{
    return @{
        @"name": @"name",
        @"num": @"number",
        @"lat": @"latitude",
        @"lockCount": @"status_total",
        @"lon": @"longitude",
        @"bikeCount": @"status_available"
        };
}

@end
