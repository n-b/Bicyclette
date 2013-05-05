//
//  BordeauxVCubCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLSubnodesCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"
#import "NSValueTransformer+TransformerKit.h"

@interface BordeauxVCubCity : XMLSubnodesCity
@end

@implementation BordeauxVCubCity

#pragma mark City Data Update

+ (void) initialize
{
    [NSValueTransformer registerValueTransformerWithName:@"FirstComponent" transformedValueClass:[NSString class]
                      returningTransformedValueWithBlock:^NSString*(NSString* value) {
                          if([value isKindOfClass:[NSString class]])
                          {
                              NSArray * words = [value componentsSeparatedByString:@" "];
                              if( [words count] > 0 )
                                  return words[0];
                          }
                          return nil;
                      }];
    [NSValueTransformer registerValueTransformerWithName:@"SecondComponent" transformedValueClass:[NSString class]
                      returningTransformedValueWithBlock:^NSString*(NSString* value) {
                          if([value isKindOfClass:[NSString class]])
                          {
                              NSArray * words = [value componentsSeparatedByString:@" "];
                              if( [words count] > 1 )
                                  return words[1];
                          }
                          return nil;
                      }];
}

- (NSArray *)updateURLStrings
{
    NSString * urlstring = @"http://data.lacub.fr/wfs?key={APIKEY}&SERVICE=WFS&VERSION=1.1.0&REQUEST=GetFeature&TYPENAME=CI_VCUB_P&SRSNAME=EPSG:4326";
    NSString * key = self.accountInfo[@"apikey"];
    urlstring = [urlstring stringByReplacingOccurrencesOfString:@"{APIKEY}"
                                                     withString:key];
    return @[urlstring];
}

- (NSDictionary *)KVCMapping
{
    return @{@"ms:NBVELOS": @"status_available",
             @"gml:pos":
                 @[@"FirstComponent:latitude",
                   @"SecondComponent:longitude"
                   ],
             @"ms:IDENT": @"number",
             @"ms:NBPLACES": @"status_free",
             @"ms:NOM": @"name"
             };
}

- (NSString *)stationElementName
{
    return @"ms:CI_VCUB_P";
}

@end
