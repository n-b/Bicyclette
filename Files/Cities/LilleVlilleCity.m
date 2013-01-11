//
//  LilleVlilleCity.m
//  Bicyclette
//
//  Created by Nicolas on 24/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInAttributes.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"
#import "NSObject+KVCMapping.h"

@interface LilleVlilleCityStationParse : NSObject
+ (void) parseData:(NSData*)data forStation:(Station*)station;
@end

@interface LilleVlilleCity : _XMLCityWithStationDataInAttributes <XMLCityWithStationDataInAttributes>
@end

@implementation LilleVlilleCity

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

- (NSString*) stationElementName
{
    return @"marker";
}

- (NSDictionary*) KVCMapping
{
    return @{@"id" : StationAttributes.number,
             @"name" : StationAttributes.name,
             @"lat" : StationAttributes.latitude,
             @"lng": StationAttributes.longitude
             };
}

#pragma mark Stations Individual Data Updates

- (void) parseData:(NSData *)data forStation:(Station *)station {
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([str length])
    {
        // if str is not nil, it means data *is* utf8.
        str = [str stringByReplacingOccurrencesOfString:@"encoding=\"utf-16\"" withString:@"encoding=\"utf-8\""];
        data = [str dataUsingEncoding:NSUTF8StringEncoding];
    }
    [LilleVlilleCityStationParse parseData:data forStation:station];
}

@end

@interface LilleVlilleCityStationParse() <NSXMLParserDelegate>
@end

@implementation LilleVlilleCityStationParse
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
    return @{@"bikes" : StationAttributes.status_available,
             @"attachs" : StationAttributes.status_free};
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString * value = [_currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([[[self KVCMapping] allKeys] containsObject:elementName])
    {
        if([value length])
            [_station setValue:value forKey:elementName withMappingDictionary:[self KVCMapping]];
    }
    else if([elementName isEqualToString:@"status"])
    {
        _station.openValue =  ! [[_currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] boolValue];
    }
    else if([elementName isEqualToString:@"station"])
    {
        _station.status_totalValue = _station.status_freeValue + _station.status_availableValue;
    }
    
    _currentString = [NSMutableString string];
}

@end
