//
//  _XMLCityWithStationDataInSubnodes
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInSubnodes.h"
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
    NSString * _parsing_urlString;
}

- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations
{
    _parsing_urlString = urlString;
    _parsing_context = context;
    _parsing_oldStations = oldStations;
    _parsing_regionsByNumber = [NSMutableDictionary new];

    // Parse stations XML
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
    
    _parsing_urlString = nil;
    _parsing_context = nil;
    _parsing_oldStations = nil;
    _parsing_regionsByNumber = nil;
}

- (NSDictionary*) patches
{
	return self.serviceInfo[@"patches"];
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

        [self setValues:_parsing_currentValues toStationWithNumber:stationNumber];
        
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

- (void) setValues:(NSDictionary*)values toStationWithNumber:(NSString*)stationNumber
{
    BOOL logParsingDetails = [[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteLogParsingDetails"];
    
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
    // Set patches
    NSDictionary * patchs = [self patches][station.number];
    BOOL hasDataPatches = patchs && ![[[patchs allKeys] arrayByRemovingObjectsInArray:[[self KVCMapping] allKeys]] isEqualToArray:[patchs allKeys]];
    if(hasDataPatches)
    {
        if(logParsingDetails)
            NSLog(@"Note : Used hardcoded fixes %@. Fixes : %@.",values, patchs);
        [station setValuesForKeysWithDictionary:patchs withMappingDictionary:[self KVCMapping]]; // Yay! again
    }
    
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
    RegionInfo * regionInfo;
    if([self hasRegions])
    {
        regionInfo = [self regionInfoFromStation:station values:values patchs:patchs requestURL:_parsing_urlString];
        if(nil==regionInfo)
        {
            if(logParsingDetails)
                NSLog(@"Invalid data : %@",values);
            [_parsing_context deleteObject:station];
            return;
        }
    }
    else
    {
        regionInfo = [RegionInfo new];
        regionInfo.number = @"anonymousregion";
        regionInfo.name = @"anonymousregion";
    }
    
    Region * region = _parsing_regionsByNumber[regionInfo.number];
    if(nil==region)
    {
        region = [[Region fetchRegionWithNumber:_parsing_context number:regionInfo.number] lastObject];
        if(region==nil)
        {
            region = [Region insertInManagedObjectContext:_parsing_context];
            region.number = regionInfo.number;
            region.name = regionInfo.number;
        }
        _parsing_regionsByNumber[regionInfo.number] = region;
    }
    station.region = region;
}

@end

