//
//  LilleVlilleCity.m
//  Bicyclette
//
//  Created by Nicolas on 24/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLAttributesCity.h"
#import "_StationParse.h"
#import "NSValueTransformer+TransformerKit.h"

@interface FixedUTF8EncodingXMLSubnodesStationParse : XMLSubnodesStationParse
@end

@interface LilleVlilleCity : XMLAttributesCity
@end

@implementation LilleVlilleCity

+ (void)initialize
{
    [NSValueTransformer registerValueTransformerWithName:@"VlilleStationStatusTransformer" transformedValueClass:[NSString class]
                      returningTransformedValueWithBlock:^NSNumber*(NSString* value) {
                          if([value isKindOfClass:[NSString class]])
                          {
                              return @(![value boolValue]);
                          }
                          return @YES;
                      }];
}

#pragma mark City Data Update

- (void) parseData:(NSData*)data
{
    // As of 2013-01-11, the data returned is utf-8, even if the xml specifies utf-16. I try to convert.
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([str length])
    {
        // if str is not nil, it means data *is* utf8.
        str = [str stringByReplacingOccurrencesOfString:@"encoding=\"utf-16\"" withString:@"encoding=\"utf-8\""];
        data = [str dataUsingEncoding:NSUTF8StringEncoding];
    }
    [super parseData:data];
}

@end

@implementation FixedUTF8EncodingXMLSubnodesStationParse

- (void)parseData:(NSData *)data
{
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([str length])
    {
        // if str is not nil, it means data *is* utf8.
        str = [str stringByReplacingOccurrencesOfString:@"encoding=\"utf-16\"" withString:@"encoding=\"utf-8\""];
        data = [str dataUsingEncoding:NSUTF8StringEncoding];
    }
    [super parseData:data];
}

@end
