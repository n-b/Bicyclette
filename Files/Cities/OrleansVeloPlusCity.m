//
//  OrleansVeloPlusCity.m
//  Bicyclette
//
//  Created by Nicolas on 14/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "OrleansVeloPlusCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"
#import "NSStringAdditions.h"

#pragma mark Stations Individual Data Updates

@interface OrleansVeloPlusStationParse : NSObject
+ (void) parseData:(NSData*)data forStation:(Station*)station;
@end

#pragma mark -

@interface OrleansVeloPlusCity () <NSXMLParserDelegate>
@end

@implementation OrleansVeloPlusCity
{
    NSManagedObjectContext * _parsing_context;
    NSMutableArray * _parsing_oldStations;
    Region * _parsing_region;
}

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return [station.name capitalizedStringWithCurrentLocale]; }

#pragma mark City Data Update

- (BOOL) hasRegions { return NO; }

- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations
{
    _parsing_context = context;
    _parsing_oldStations = oldStations;
    
    // Create an anonymous region
    _parsing_region = [[Region fetchRegionWithNumber:_parsing_context number:@"anonymousregion"] lastObject];
    if(_parsing_region==nil)
    {
        _parsing_region = [Region insertInManagedObjectContext:_parsing_context];
        _parsing_region.number = @"anonymousregion";
        _parsing_region.name = @"anonymousregion";
    }

    // Parse stations XML
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
    
    _parsing_region = nil;
    _parsing_context = nil;
    _parsing_oldStations = nil;
}

- (NSDictionary*) KVCMapping
{
    return @{@"id" : StationAttributes.number,
             @"lat" : StationAttributes.latitude,
             @"lng": StationAttributes.longitude,
             @"name" : StationAttributes.name,
             @"name" : StationAttributes.address};
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"marker"])
    {
        // Find Existing Station
        Station * station = [_parsing_oldStations firstObjectWithValue:attributeDict[@"number"] forKeyPath:StationAttributes.number];
        if(station)
        {
            // found existing
            [_parsing_oldStations removeObject:station];
        }
        else
        {
            if(_parsing_oldStations.count)
                NSLog(@"Note : new station found after update : %@", attributeDict);
            station = [Station insertInManagedObjectContext:_parsing_context];
        }

        // Set Values
		[station setValuesForKeysWithDictionary:attributeDict withMappingDictionary:[self KVCMapping]]; // Yay!

        // Set Station
        station.region = _parsing_region;
    }
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
