//
//  NextBikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 24/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "NextBikeCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"

@interface NextBikeCity () <NSXMLParserDelegate>
@end

@implementation NextBikeCity
{
    NSManagedObjectContext * _parsing_context;
    NSMutableArray * _parsing_oldStations;
    Region * _parsing_region;
}

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
    return @{@"uid" : StationAttributes.number,
             @"name" : StationAttributes.name,
             @"lat" : StationAttributes.latitude,
             @"lng": StationAttributes.longitude,
             @"bikes": StationAttributes.status_available
             };
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"place"])
    {
        // Find Existing Station
        Station * station = [_parsing_oldStations firstObjectWithValue:attributeDict[@"id"] forKeyPath:StationAttributes.number];
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
        
        station.status_totalValue = station.status_freeValue + station.status_availableValue;
        station.status_date = [NSDate date];
        
        // Set Station
        station.region = _parsing_region;
    }
}

@end
