//
//  CyclocityCity.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CyclocityCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"
#import "NSStringAdditions.h"
#import "CyclocityStationParse.h"

@implementation CyclocityCity
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

#pragma mark Stations Individual Data Updates

- (void) parseData:(NSData *)data forStation:(Station *)station { [CyclocityStationParse parseData:data forStation:station]; }

#pragma mark City Data Updates

- (NSString*) stationElementName
{
    return @"marker";
}

- (NSString*) stationNumberFromStationValues:(NSDictionary*)values
{
    return @"number";
}

- (NSDictionary*) KVCMapping
{
    return @{
        @"address" : StationAttributes.address,
        @"bonus" : StationAttributes.bonus,
        @"fullAddress" : StationAttributes.fullAddress,
        @"name" : StationAttributes.name,
        @"number" : StationAttributes.number,
        @"open" : StationAttributes.open,
        
        @"lat" : StationAttributes.latitude,
        @"lng" : StationAttributes.longitude,
        };
}

@end

