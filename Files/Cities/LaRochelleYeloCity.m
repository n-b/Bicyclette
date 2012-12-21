//
//  LaRochelleYeloCity.m
//  Bicyclette
//
//  Created by Nicolas on 18/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "LaRochelleYeloCity.h"
#import "BicycletteCity.mogenerated.h"
#import "CollectionsAdditions.h"
#import "NSObject+KVCMapping.h"
#import "NSStringAdditions.h"

@interface LaRochelleYeloCity () <NSXMLParserDelegate>
@end

@implementation LaRochelleYeloCity

#pragma mark Annotations

- (NSString *) title { return @"Yélo"; };
- (NSString *) titleForStation:(Station *)station { return station.name; };

#pragma mark City Data Update

- (BOOL) hasRegions { return NO; }
- (NSArray *)updateURLStrings { return @[ @"http://www.rtcr.fr/ct_93_297__Carte_du_libre_service_velos.html" ]; };

- (NSDictionary*) KVCMapping
{
    return @{@"num": StationAttributes.number,
             @"lat" : StationAttributes.latitude,
             @"lon": StationAttributes.longitude,
             @"name" : StationAttributes.name,
             @"bikeCount" : StationAttributes.status_available,
             @"lockCount" : StationAttributes.status_total,
             };
}

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

@end
