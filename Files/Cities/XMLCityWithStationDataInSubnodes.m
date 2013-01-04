//
//  XMLCityWithStationDataInSubnodes.m
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLCityWithStationDataInSubnodes.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"

// Allow me to call methods of subclasses
@interface _XMLCityWithStationDataInSubnodes (XMLCityWithStationDataInSubnodes) <XMLCityWithStationDataInSubnodes>
@end

#pragma mark -

@implementation _XMLCityWithStationDataInSubnodes
{
    NSManagedObjectContext * _parsing_context;
    NSMutableArray * _parsing_oldStations;
    NSMutableDictionary * _parsing_currentValues;
    NSMutableString * _parsing_currentString;
    Region * _parsing_region;
}

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

#pragma mark -

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _parsing_currentString = [NSMutableString new];
    if([elementName isEqualToString:[self stationElementName]])
        _parsing_currentValues = [NSMutableDictionary new];
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_parsing_currentString appendString:string];
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:[self stationElementName]]) // End of station dict
    {
        NSString * keyForNumber = [[self KVCMapping] allKeysForObject:StationAttributes.number][0]; // There *must* be a key mapping to "number" in the KVCMapping dictionary.
        
        // Find Existing Station
        Station * station = [_parsing_oldStations firstObjectWithValue:_parsing_currentValues[keyForNumber] forKeyPath:StationAttributes.number];
        if(station)
        {
            // found existing
            [_parsing_oldStations removeObject:station];
        }
        else
        {
            if(_parsing_oldStations.count && [[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteLogParsingDetails"])
                NSLog(@"Note : new station found after update : %@", _parsing_currentValues);
            station = [Station insertInManagedObjectContext:_parsing_context];
        }
        
        // Set Values
		[station setValuesForKeysWithDictionary:_parsing_currentValues withMappingDictionary:[self KVCMapping]]; // Yay!
        
        // Build missing status, if needed
        if([[[self KVCMapping] allKeysForObject:StationAttributes.status_total] count]==0)
        {
            // "Total" is not in data
            station.status_totalValue = station.status_freeValue + station.status_availableValue;
        }
        else if ([[[self KVCMapping] allKeysForObject:StationAttributes.status_free] count]==0)
        {
            // "Free" is not in data
            station.status_freeValue = station.status_totalValue - station.status_availableValue;
        }
        
        // Set Date to now
        station.status_date = [NSDate date];
        
        // Set Region to "anonymous"
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

