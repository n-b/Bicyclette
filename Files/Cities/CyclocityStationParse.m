//
//  CyclocityStationParse.m
//  Bicyclette
//
//  Created by Nicolas on 14/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CyclocityStationParse.h"
#import "NSObject+KVCMapping.h"
#import "Station.h"

@interface CyclocityStationParse() <NSXMLParserDelegate>
@end

@implementation CyclocityStationParse
{
    Station * _station;
    NSMutableString * _currentString;
}

+ (void) parseData:(NSData*)data forStation:(Station*)station
{
    [[self new] parseData:data inStation:station];
}

- (void) parseData:(NSData*)data inStation:(Station*)station
{
    _station = station;
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    _currentString = [NSMutableString string];
    [parser parse];
    _currentString = nil;
    _station = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentString appendString:string];
}

- (NSDictionary*) KVCMapping
{
    return @{@"available" : @"status_available",
             @"free" : @"status_free",
             @"ticket": @"status_ticket",
             @"total" : @"status_total"};
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString * value = [_currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _currentString = [NSMutableString string];
    if([value length])
        [_station setValue:value forKey:elementName withMappingDictionary:[self KVCMapping]];
}

@end
