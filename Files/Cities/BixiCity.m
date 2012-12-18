//
//  BixiCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BixiCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"

#pragma mark -


@interface _BixiCity () <NSXMLParserDelegate>
@end

@implementation _BixiCity
{
    NSManagedObjectContext * _parsing_context;
    NSMutableArray * _parsing_oldStations;
    NSMutableDictionary * _parsing_currentValues;
    NSMutableString * _parsing_currentString;
    Region * _parsing_region;
}

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return station.name; }

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
             @"name" : StationAttributes.name,
             @"lat" : StationAttributes.latitude,
             @"long": StationAttributes.longitude,
             @"nbBikes": StationAttributes.status_available,
             @"nbEmptyDocks": StationAttributes.status_free,
             };
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _parsing_currentString = [NSMutableString new];
    if([elementName isEqualToString:@"station"])
        _parsing_currentValues = [NSMutableDictionary new];
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_parsing_currentString appendString:string];
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"station"]) // End of station dict
    {
        // Find Existing Station
        Station * station = [_parsing_oldStations firstObjectWithValue:_parsing_currentValues[@"id"] forKeyPath:StationAttributes.number];
        if(station)
        {
            // found existing
            [_parsing_oldStations removeObject:station];
        }
        else
        {
            if(_parsing_oldStations.count)
                NSLog(@"Note : new station found after update : %@", _parsing_currentValues);
            station = [Station insertInManagedObjectContext:_parsing_context];
        }
        
        // Set Values
		[station setValuesForKeysWithDictionary:_parsing_currentValues withMappingDictionary:[self KVCMapping]]; // Yay!
        
        station.status_totalValue = station.status_freeValue + station.status_availableValue;
        station.status_date = [NSDate date];
        
        // Set Station
        station.region = _parsing_region;
        
        // Clear values
        _parsing_currentValues = nil;
    }
    else
    {
        // Accumulate values
        NSString * value = [_parsing_currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(value)
            [_parsing_currentValues setObject:value forKey:elementName];
        _parsing_currentString = nil;
    }
}

@end

