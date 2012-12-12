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

@interface CyclocityCity(Subclasses) <CyclocityCityParsing>
@end

@implementation RegionInfo
@end

/****************************************************************************/
#pragma mark -

@interface CyclocityCity () <NSXMLParserDelegate>
@property NSManagedObjectContext * parsing_context;
@property NSMutableDictionary * parsing_regionsByNumber;
@property NSMutableArray * parsing_oldStations;
@end

@implementation CyclocityCity

- (BOOL) hasRegions
{
    return [self respondsToSelector:@selector(regionInfoFromStation:patchs:)];
}

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

/****************************************************************************/
#pragma mark Parsing

- (void) parseData:(NSData *)data
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations
{
    self.parsing_context = context;
    self.parsing_oldStations = oldStations;
    self.parsing_regionsByNumber = [NSMutableDictionary new];

    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];

    self.parsing_context = nil;
    self.parsing_oldStations = nil;
    self.parsing_regionsByNumber = nil;
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
        @"address" : @"address",
        @"bonus" : @"bonus",
        @"fullAddress" : @"fullAddress",
        @"name" : @"name",
        @"number" : @"number",
        @"open" : @"open",
        
        @"lat" : @"latitude",
        @"lng" : @"longitude"
        };
    
    return s_mapping;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"marker"])
	{
        // Filter out closed stations
        if( ! [attributeDict[@"open"] boolValue] )
        {
            NSLog(@"Note : Ignored closed station : %@", attributeDict[@"name"]);
            return;
        }
        
        // Find Existing Stations
        Station * station = [self.parsing_oldStations firstObjectWithValue:attributeDict[@"number"] forKeyPath:StationAttributes.number];
        if(station)
        {
            // found existing
            [self.parsing_oldStations removeObject:station];
        }
        else
        {
            if(self.parsing_oldStations.count)
                NSLog(@"Note : new station found after update : %@", attributeDict);
            station = [Station insertInManagedObjectContext:self.parsing_context];
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
                [self.parsing_context deleteObject:station];
                return;
            }
        }
        else
        {
            regionInfo = [RegionInfo new];
            regionInfo.number = @"anonymousregion";
            regionInfo.name = @"anonymousregion";
        }
        
        // Keep regions in an array locally, to avoid fetching a Region for every Station parsed.
        Region * region = (self.parsing_regionsByNumber)[regionInfo.number];
        if(nil==region)
        {
            region = [[Region fetchRegionWithNumber:self.parsing_context number:regionInfo.number] lastObject];
            if(region==nil)
            {
                region = [Region insertInManagedObjectContext:self.parsing_context];
                region.number = regionInfo.number;
                region.name = regionInfo.name;
            }
            (self.parsing_regionsByNumber)[regionInfo.number] = region;
        }
        station.region = region;
    }
}

@end

