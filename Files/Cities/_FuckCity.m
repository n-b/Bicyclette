//
//  TempCityClass.m
//  
//
//  Created by Nicolas on 04/01/13.
//
//

#import "_FuckCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"

// Allow me to call methods of subclasses
@interface _FuckCity (XMLCity) <FuckCity>
@end

@implementation _FuckCity
{
    NSManagedObjectContext * _parsing_context;
    NSMutableArray * _parsing_oldStations;
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
    
    [self fuckParseData:data];
    
    _parsing_urlString = nil;
    _parsing_context = nil;
    _parsing_oldStations = nil;
    _parsing_regionsByNumber = nil;
}

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
