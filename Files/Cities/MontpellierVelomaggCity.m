//
//  MontpellierVelomaggCity.m
//  Bicyclette
//
//  Created by Nicolas on 02/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "MontpellierVelomaggCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"
#import "NSStringAdditions.h"

#pragma mark -

// XML
// No region
// station data in node attributes

@interface MontpellierVelomaggCity () <NSXMLParserDelegate>
@end

@implementation MontpellierVelomaggCity
{
    NSManagedObjectContext * _parsing_context;
    NSMutableArray * _parsing_oldStations;
    Region * _parsing_region;
}

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return [[[station.name stringByTrimmingZeros] stringByDeletingPrefix:station.number] stringByTrimmingWhitespace]; }

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
             @"la" : StationAttributes.latitude,
             @"lg": StationAttributes.longitude,
             @"na" : StationAttributes.name,
             @"av" : StationAttributes.status_available,
             @"fr" : StationAttributes.status_free,
             @"to" : StationAttributes.status_total};
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"si"])
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
            if(_parsing_oldStations.count && [[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteLogParsingDetails"])
                NSLog(@"Note : new station found after update : %@", attributeDict);
            station = [Station insertInManagedObjectContext:_parsing_context];
        }
        
        // Set Values
		[station setValuesForKeysWithDictionary:attributeDict withMappingDictionary:[self KVCMapping]]; // Yay!
        
        station.status_date = [NSDate date];
        
        // Set Station
        station.region = _parsing_region;
    }
}

@end
