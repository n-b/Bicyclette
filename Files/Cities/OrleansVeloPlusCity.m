//
//  OrleansVeloPlusCity.m
//  Bicyclette
//
//  Created by Nicolas on 14/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInAttributes.h"
#import "BicycletteCity.mogenerated.h"
#import "_StationParse.h"
#import "NSStringAdditions.h"
#import "NSValueTransformer+TransformerKit.h"

#pragma mark -

@interface OrleansVeloPlusCity : _XMLCityWithStationDataInAttributes <XMLCityWithStationDataInAttributes>
@end

#pragma mark -

@implementation OrleansVeloPlusCity

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return [station.name capitalizedStringWithCurrentLocale]; }

#pragma mark City Data Update

- (NSString*) stationElementName
{
    return @"marker";
}

- (NSDictionary*) KVCMapping
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSValueTransformer registerValueTransformerWithName:@"OrleansStationStatusTransformer" transformedValueClass:[NSString class]
                          returningTransformedValueWithBlock:^NSNumber*(NSString* value) {
                              if([value isKindOfClass:[NSString class]])
                              {
                                  return @(![value isEqualToString:@"En maintenance"]);
                              }
                              return @YES;
                          }];
    });

    return @{@"id" : StationAttributes.number,
             @"lat" : StationAttributes.latitude,
             @"lng": StationAttributes.longitude,
             @"name" : StationAttributes.name,
             
             @"bikes" : StationAttributes.status_available,
             @"attachs" : StationAttributes.status_free,
             @"status" : @"OrleansStationStatusTransformer:open"};
}

#pragma mark Stations Individual Data Updates

- (Class) stationStatusParsingClass { return [XMLSubnodesStationParse class]; }

@end
