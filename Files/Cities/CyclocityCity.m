//
//  CyclocityCity.m
//  
//
//  Created by Nicolas on 12/12/12.
//
//

#import "CyclocityCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSError+MultipleErrorsCombined.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"

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


/****************************************************************************/
#pragma mark Parsing

- (void) parseData:(NSData*)data
{
    __block NSError * validationErrors;
    [self performUpdates:^(NSManagedObjectContext *updateContext) {
        // Get Old Stations Names
        NSError * requestError = nil;
        
        NSFetchRequest * oldStationsRequest = [NSFetchRequest fetchRequestWithEntityName:[Station entityName]];
        self.parsing_oldStations =  [[updateContext executeFetchRequest:oldStationsRequest error:&requestError] mutableCopy];
        
        // Parsing
        self.parsing_regionsByNumber = [NSMutableDictionary dictionary];
        self.parsing_context = updateContext;
        NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
        parser.delegate = self;
        [parser parse];
        
        // Validate all stations (and delete invalid) before computing coordinates
        for (Region *r in [self.parsing_regionsByNumber allValues]) {
            for (Station *s in [r.stations copy]) {
                if(![s validateForInsert:&validationErrors])
                {
                    s.region = nil;
                    [updateContext deleteObject:s];
                }
            }
        }
        
        // Post processing :
        // Compute regions coordinates
        // and reorder stations in regions
        for (Region * region in [self.parsing_regionsByNumber allValues]) {
//            [region.stationsSet sortUsingComparator:^NSComparisonResult(Station* obj1, Station* obj2) {
//                return [obj1.name compare:obj2.name];
//            }];
            [region setupCoordinates];
        }
        self.parsing_regionsByNumber = nil;
        
        // Delete Old Stations
        for (Station * oldStation in self.parsing_oldStations) {
            NSLog(@"Note : old station deleted after update : %@", oldStation);
            [updateContext deleteObject:oldStation];
        }
        self.parsing_oldStations = nil;
        
        self.parsing_context = nil;
    } saveCompletion:^(NSNotification *contextDidSaveNotification) {
        NSMutableDictionary * userInfo = [@{BicycletteCityNotifications.keys.dataChanged : @(YES)} mutableCopy];
        if (validationErrors)
            userInfo[BicycletteCityNotifications.keys.saveErrors] = [validationErrors underlyingErrors];
        [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.updateSucceeded object:self
                                                          userInfo:userInfo];
    }];
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

