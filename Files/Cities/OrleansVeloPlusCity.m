//
//  OrleansVeloPlusCity.m
//  Bicyclette
//
//  Created by Nicolas on 14/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLAttributesCity.h"
#import "NSStringAdditions.h"
#import "NSValueTransformer+TransformerKit.h"
#import "_StationParse.h"

@interface OrleansVeloPlusCity : XMLAttributesCity
@end

@implementation OrleansVeloPlusCity

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return [station.name capitalizedStringWithCurrentLocale]; }

#pragma mark City Data Update

+ (void)initialize
{
    [NSValueTransformer registerValueTransformerWithName:@"OrleansStationStatusTransformer" transformedValueClass:[NSString class]
                      returningTransformedValueWithBlock:^NSNumber*(NSString* value) {
                          if([value isKindOfClass:[NSString class]])
                          {
                              return @(![value isEqualToString:@"En maintenance"]);
                          }
                          return @YES;
                      }];
}

- (NSArray *)updateURLStrings
{
    return @[@"https://www.agglo-veloplus.fr/component/data_1.xml"];
}

- (NSString *) detailsURLStringForStation:(Station*)station
{
    return [@"https://www.agglo-veloplus.fr/getStatusBorne?idBorne=" stringByAppendingString:station.number];
}

- (Class)stationStatusParsingClass
{
    return [XMLSubnodesStationParse class];
}

- (NSDictionary *)KVCMapping
{
    return @{@"status": @"OrleansStationStatusTransformer:open",
             @"id": @"number",
             @"bikes": @"status_available",
             @"lat": @"latitude",
             @"lng": @"longitude",
             @"name": @"name",
             @"attachs": @"status_free"
             };
}

- (NSString *)stationElementName
{
    return @"marker";
}

@end
