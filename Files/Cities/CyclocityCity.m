//
//  CyclocityCity.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CyclocityCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"
#import "NSStringAdditions.h"
#import "CyclocityStationParse.h"

// Allow me to use method implemented in subclasses
@interface _CyclocityCity(CyclocityCity) <CyclocityCity>
@end

@implementation RegionInfo
@end

#pragma mark -

@interface _CyclocityCity () <NSXMLParserDelegate>
@end

@implementation _CyclocityCity
{
    NSManagedObjectContext * _parsing_context;
    NSMutableDictionary * _parsing_regionsByNumber;
    NSMutableArray * _parsing_oldStations;
}
#pragma mark Annotations

- (NSString*) titleForStation:(Station*)station
{
    NSString * title = station.name;
    title = [title stringByTrimmingZeros];
    title = [title stringByDeletingPrefix:station.number];
    title = [title stringByTrimmingWhitespace];
    title = [title stringByDeletingPrefix:@"-"];
    title = [title stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    title = [title stringByTrimmingWhitespace];
    title = [title capitalizedStringWithCurrentLocale];
    return title;
}

#pragma mark Stations Individual Data Updates

- (void) parseData:(NSData *)data forStation:(Station *)station { [CyclocityStationParse parseData:data forStation:station]; }

#pragma mark City Data Updates

- (BOOL) hasRegions
{
    return [self respondsToSelector:@selector(regionInfoFromStation:patchs:)];
}

- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations
{
    _parsing_context = context;
    _parsing_oldStations = oldStations;
    _parsing_regionsByNumber = [NSMutableDictionary new];

    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];

    _parsing_context = nil;
    _parsing_oldStations = nil;
    _parsing_regionsByNumber = nil;
}

- (NSDictionary*) patches
{
	return self.serviceInfo[@"patches"];
}

- (NSDictionary*) KVCMapping
{
    static NSDictionary * s_mapping = nil;
    if(nil==s_mapping)
        s_mapping = @{
        @"address" : StationAttributes.address,
        @"bonus" : StationAttributes.bonus,
        @"fullAddress" : StationAttributes.fullAddress,
        @"name" : StationAttributes.name,
        @"number" : StationAttributes.number,
        @"open" : StationAttributes.open,
        
        @"lat" : StationAttributes.latitude,
        @"lng" : StationAttributes.longitude,
        };
    
    return s_mapping;
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
        
        // Set Values and hardcoded fixes
		[station setValuesForKeysWithDictionary:attributeDict withMappingDictionary:[self KVCMapping]]; // Yay!
		NSDictionary * patchs = [self patches][station.number];
        BOOL hasDataPatches = patchs && ![[[patchs allKeys] arrayByRemovingObjectsInArray:[[self KVCMapping] allKeys]] isEqualToArray:[patchs allKeys]];
		if(hasDataPatches)
		{
			NSLog(@"Note : Used hardcoded fixes %@. Fixes : %@.",attributeDict, patchs);
			[station setValuesForKeysWithDictionary:patchs withMappingDictionary:[self KVCMapping]]; // Yay! again
		}
        
        // Setup region
        RegionInfo * regionInfo;
        
        if([self hasRegions])
        {
            regionInfo = [self regionInfoFromStation:station patchs:patchs];
            if(nil==regionInfo)
            {
                NSLog(@"Invalid data : %@",attributeDict);
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
        
        // Set Region
        // Keep regions in an array locally, to avoid fetching a Region for every Station parsed.
        Region * region = _parsing_regionsByNumber[regionInfo.number];
        if(nil==region)
        {
            region = [[Region fetchRegionWithNumber:_parsing_context number:regionInfo.number] lastObject];
            if(region==nil)
            {
                region = [Region insertInManagedObjectContext:_parsing_context];
                region.number = regionInfo.number;
                region.name = regionInfo.name;
            }
            _parsing_regionsByNumber[regionInfo.number] = region;
        }
        station.region = region;
    }
}

@end

