//
//  OrleansVeloPlusCity.m
//  Bicyclette
//
//  Created by Nicolas on 14/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInAttributes.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "NSStringAdditions.h"

#pragma mark -

@interface OrleansVeloPlusCity : _XMLCityWithStationDataInAttributes <XMLCityWithStationDataInAttributes>
@end

@interface OrleansVeloPlusStationParse : NSObject
+ (void) parseData:(NSData*)data forStation:(Station*)station;
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

- (NSString*) stationNumberFromStationValues:(NSDictionary*)values
{
    return values[@"id"];
}

- (NSDictionary*) KVCMapping
{
    return @{@"id" : StationAttributes.number,
             @"lat" : StationAttributes.latitude,
             @"lng": StationAttributes.longitude,
             @"name" : StationAttributes.name,
             @"name" : StationAttributes.address};
}

#pragma mark Stations Individual Data Updates

- (NSString *)detailsURLStringForStation:(Station *)station { return [NSString stringWithFormat:@"https://www.agglo-veloplus.fr/getStatusBorne?idBorne=%@",station.number]; }

- (void) parseData:(NSData *)data forStation:(Station *)station { [OrleansVeloPlusStationParse parseData:data forStation:station]; }

@end

#pragma mark Stations Individual Data Updates

@interface OrleansVeloPlusStationParse() <NSXMLParserDelegate>
@end

@implementation OrleansVeloPlusStationParse
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
             @"attachs" : StationAttributes.status_free,
             @"total" : StationAttributes.status_total};
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
        _station.openValue = [_currentString isEqualToString:@"En service"];
    }
    else if([elementName isEqualToString:@"station"])
    {
        _station.status_totalValue = _station.status_freeValue + _station.status_availableValue;
    }

    _currentString = [NSMutableString string];
}

@end
