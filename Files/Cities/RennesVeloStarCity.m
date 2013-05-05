//
//  RennesVeloStarCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLSubnodesCity.h"
#import "NSStringAdditions.h"

@interface RennesVeloStarCity : XMLSubnodesCity
@end

@implementation RennesVeloStarCity

- (NSArray *)updateURLStrings
{
    NSString * urlstring = @"http://data.keolis-rennes.com/xml/?version=1.0&key={APIKEY}&cmd=getstation";
    NSString * key = self.accountInfo[@"apikey"];
    urlstring = [urlstring stringByReplacingOccurrencesOfString:@"{APIKEY}"
                                                     withString:key];
    return @[urlstring];
}

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return [station.name capitalizedStringWithCurrentLocale]; }

- (NSDictionary *)KVCMapping
{
    return @{@"number": @"number",
             @"name": @"name",
             @"longitude": @"longitude",
             @"latitude": @"latitude",
             @"slotsavailable": @"status_free",
             @"bikesavailable": @"status_available",
             @"state": @"open",
             @"pos": @"status_ticket"
             };
}

- (NSString *)stationElementName
{
    return @"station";
}

@end
