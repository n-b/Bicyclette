//
//  SimpleStationsListBicycletteCity.m
//  Bicyclette
//
//  Created by Nicolas on 21/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "SimpleStationsListBicycletteCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"

// Allow me to call methods of subclasses
@interface _SimpleStationsListBicycletteCity (SimpleStationsListBicycletteCity) <SimpleStationsListBicycletteCity>
@end

@implementation _SimpleStationsListBicycletteCity

- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations
{
    // Create an anonymous region
    Region * region = [[Region fetchRegionWithNumber:context number:@"anonymousregion"] lastObject];
    if(region==nil)
    {
        region = [Region insertInManagedObjectContext:context];
        region.number = @"anonymousregion";
        region.name = @"anonymousregion";
    }
    
    id json = [self stationAttributesArraysFromData:data];
    
    NSString * keyForNumber = [[self KVCMapping] allKeysForObject:StationAttributes.number][0]; // There *must* be a key mapping to "number" in the KVCMapping dictionary.
    
    for (NSDictionary * attributeDict in json) {
        Station * station = [oldStations firstObjectWithValue:attributeDict[keyForNumber] forKeyPath:StationAttributes.number];
        if(station)
        {
            // found existing
            [oldStations removeObject:station];
        }
        else
        {
            if(oldStations.count)
                NSLog(@"Note : new station found after update : %@", attributeDict);
            station = [Station insertInManagedObjectContext:context];
        }
        
        [station setValuesForKeysWithDictionary:attributeDict withMappingDictionary:[self KVCMapping]];

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
        station.region = region;
    }
}


@end


/****************************************************************************/
#pragma mark JSON

@interface _SimpleJSONStationsListBicycletteCity (SimpleJSONStationsListBicycletteCity) <SimpleJSONStationsListBicycletteCity>
@end

@implementation _SimpleJSONStationsListBicycletteCity
- (NSArray*) stationAttributesArraysFromData:(NSData*)data
{
    NSError * error;
    id res = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(!res)
        NSLog(@"Error parsing JSON in %@ : %@",self,error);

    if([self respondsToSelector:@selector(keyPathToStationsLists)])
    {
        if([res isKindOfClass:[NSDictionary class]])
        {
            res = [res valueForKeyPath:[self keyPathToStationsLists]];
        }
        else
        {
            NSLog(@"Error parsing JSON in %@ : result should be a dictionary",self);
            res = nil;
        }
    }
    
    if(![res isKindOfClass:[NSArray class]])
    {
        NSLog(@"Error parsing JSON in %@ : result should be an array",self);
        res = nil;
    }
    return res;
}
@end
