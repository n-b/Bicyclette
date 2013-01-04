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
    NSMutableDictionary * _parsing_regionsByNumber;
}

- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations
{
    _parsing_context = context;
    _parsing_oldStations = oldStations;
    _parsing_regionsByNumber = [NSMutableDictionary new];

    // Parse stations XML
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
    
    _parsing_context = nil;
    _parsing_oldStations = nil;
    _parsing_regionsByNumber = nil;
}

- (BOOL) hasRegions
{
    return [self respondsToSelector:@selector(regionNumberFromStationValues:)];
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
        NSString * stationNumber = [self stationNumberFromStationValues:_parsing_currentValues];
        NSString * regionNumber;
        if([self respondsToSelector:@selector(regionNumberFromStationValues:)])
            regionNumber = [self regionNumberFromStationValues:_parsing_currentValues];
        else
            regionNumber = @"anonymousregion";

        [self setValues:_parsing_currentValues toStationWithNumber:stationNumber regionNumber:regionNumber];
        
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

#pragma mark -

- (void) setValues:(NSDictionary*)values toStationWithNumber:(NSString*)stationNumber regionNumber:(NSString*)regionNumber
{
    //
    // Find Existing Station
    Station * station = [_parsing_oldStations firstObjectWithValue:values[stationNumber] forKeyPath:StationAttributes.number];
    if(station)
    {
        // found existing
        [_parsing_oldStations removeObject:station];
    }
    else
    {
        if(_parsing_oldStations.count && [[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteLogParsingDetails"])
            NSLog(@"Note : new station found after update : %@", values);
        station = [Station insertInManagedObjectContext:_parsing_context];
    }
    
    //
    // Set Values
    [station setValuesForKeysWithDictionary:values withMappingDictionary:[self KVCMapping]]; // Yay!
    
    //
    // Build missing status, if needed
    if([[[self KVCMapping] allKeysForObject:StationAttributes.status_available] count])
    {
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
    }

    //
    // Set Region
    Region * region = _parsing_regionsByNumber[regionNumber];
    if(nil==region)
    {
        region = [[Region fetchRegionWithNumber:_parsing_context number:regionNumber] lastObject];
        if(region==nil)
        {
            region = [Region insertInManagedObjectContext:_parsing_context];
            region.number = regionNumber;
            region.name = regionNumber;
        }
        _parsing_regionsByNumber[regionNumber] = region;
    }
    station.region = region;
}

@end

