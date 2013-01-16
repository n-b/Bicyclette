//
//  OrleansVeloPlusCity.m
//  Bicyclette
//
//  Created by Nicolas on 14/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInAttributes.h"
#import "NSStringAdditions.h"
#import "NSValueTransformer+TransformerKit.h"

@interface OrleansVeloPlusCity : _XMLCityWithStationDataInAttributes
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

@end
