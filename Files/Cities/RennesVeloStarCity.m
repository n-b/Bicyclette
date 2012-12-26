//
//  RennesVeloStarCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "RennesVeloStarCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"
#import "NSStringAdditions.h"

#pragma mark -

@interface RennesVeloStarCity () <NSXMLParserDelegate>
@end

@implementation RennesVeloStarCity
{
    NSManagedObjectContext * _parsing_context;
    NSMutableDictionary * _parsing_regionsByNumber;
    NSMutableArray * _parsing_oldStations;
    NSMutableDictionary * _parsing_currentValues;
    NSMutableString * _parsing_currentString;
}

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return [station.name capitalizedStringWithCurrentLocale]; }
- (NSString *) titleForRegion:(Region*)region { return region.name; }
- (NSString *) subtitleForRegion:(Region*)region { return @""; }


#pragma mark City Data Update

- (BOOL) hasRegions { return YES; }

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

- (NSDictionary*) KVCMapping
{
    return @{@"number" : StationAttributes.number,
             @"name" : StationAttributes.name,
             @"state" : StationAttributes.open,
             @"latitude" : StationAttributes.latitude,
             @"longitude": StationAttributes.longitude,
             @"slotsavailable": StationAttributes.status_free,
             @"bikesavailable": StationAttributes.status_available,
             @"pos":StationAttributes.status_ticket,
             };
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _parsing_currentString = [NSMutableString new];
    if([elementName isEqualToString:@"station"])
        _parsing_currentValues = [NSMutableDictionary new];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_parsing_currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"station"]) // End of station dict
    {
        // Find Existing Station
        Station * station = [_parsing_oldStations firstObjectWithValue:_parsing_currentValues[@"number"] forKeyPath:StationAttributes.number];
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
        
        station.status_totalValue = station.status_freeValue + station.status_availableValue;
        station.status_date = [NSDate date];

        // Set Region
        // Keep regions in an array locally, to avoid fetching a Region for every Station
        NSString * regionName = _parsing_currentValues[@"district"];
        Region * region = _parsing_regionsByNumber[regionName];
        if(nil==region)
        {
            region = [[Region fetchRegionWithNumber:_parsing_context number:regionName] lastObject];
            if(region==nil)
            {
                region = [Region insertInManagedObjectContext:_parsing_context];
                region.number = regionName;
                region.name = regionName;
            }
            _parsing_regionsByNumber[regionName] = region;
        }
        station.region = region;
        
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
