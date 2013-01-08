//
//  BordeauxVCubCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInSubnodes.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"
#import "NSValueTransformer+TransformerKit.h"

@interface BordeauxVCubCity : _XMLCityWithStationDataInSubnodes <XMLCityWithStationDataInSubnodes>
@end

@implementation BordeauxVCubCity

#pragma mark City Data Update

- (NSString*) stationElementName
{
    return @"ms:CI_VCUB_P";
}

- (NSDictionary*) KVCMapping
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSValueTransformer registerValueTransformerWithName:@"firstComponent" transformedValueClass:[NSString class]
                          returningTransformedValueWithBlock:^NSString*(NSString* value) {
                              if([value isKindOfClass:[NSString class]])
                              {
                                  NSArray * words = [value componentsSeparatedByString:@" "];
                                  if( [words count] > 0 )
                                      return words[0];
                              }
                              return nil;
                          }];
        [NSValueTransformer registerValueTransformerWithName:@"secondComponent" transformedValueClass:[NSString class]
                          returningTransformedValueWithBlock:^NSString*(NSString* value) {
                              if([value isKindOfClass:[NSString class]])
                              {
                                  NSArray * words = [value componentsSeparatedByString:@" "];
                                  if( [words count] > 1 )
                                      return words[1];
                              }
                              return nil;
                          }];
    });

    return @{@"ms:IDENT" : StationAttributes.number,
             @"ms:NOM" : StationAttributes.name,
             @"gml:pos" : @[@"firstComponent:latitude",@"secondComponent:longitude"],
             @"ms:NBPLACES": StationAttributes.status_free,
             @"ms:NBVELOS": StationAttributes.status_available,
             };
}

@end
