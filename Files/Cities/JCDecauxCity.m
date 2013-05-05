//
//  JCDecauxCity.m
//  Bicyclette
//
//  Created by Nicolas on 05/05/13.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "FlatJSONListCity.h"
#import "NSStringAdditions.h"
#import "NSValueTransformer+TransformerKit.h"

@interface JCDecauxCity : FlatJSONListCity
@end

@implementation JCDecauxCity

+ (void) initialize
{
    [NSValueTransformer registerValueTransformerWithName:@"JCDecauxCityStatusTransformer" transformedValueClass:[NSNumber class]
                      returningTransformedValueWithBlock:^NSNumber*(NSString* value) {
                          if([value isKindOfClass:[NSString class]]) {
                              return @([value isEqualToString:@"OPEN"]);
                          }
                          return nil;
                      }];
}

- (NSString*)contractName
{
    if([self.serviceInfo[@"jcdecaux_contract"] length]) {
        return self.serviceInfo[@"jcdecaux_contract"];
    } else {
        return self.cityName;
    }
}

- (NSArray *)updateURLStrings
{
    return @[[NSString stringWithFormat:@"https://api.jcdecaux.com/vls/v1/stations?contract=%@&apiKey=%@",
              [self contractName],
              self.accountInfo[@"apikey"]
              ]];
}

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

- (NSDictionary *)KVCMapping
{
    return @{@"address": @"address",
             @"available_bike_stands": @"status_free",
             @"available_bikes": @"status_available",
             @"bike_stands": @"status_total",
             @"bonus": @"bonus",
             @"name": @"name",
             @"number": @"number",
             @"position.lng": @"longitude",
             @"position.lat": @"latitude",
             @"status": @"JCDecauxCityStatusTransformer:open",
             };
}

@end
