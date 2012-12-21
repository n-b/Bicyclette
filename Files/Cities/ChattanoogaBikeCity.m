//
//  ChattanoogaBikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 21/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "ChattanoogaBikeCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"

@protocol SimpleJSONBicycletteCity
- (NSArray*) stationAttributesArraysFromData:(NSData*)data;
- (NSDictionary*) KVCMapping;
@end

@interface _SimpleJSONBicycletteCity (Subclasses) <SimpleJSONBicycletteCity>

@end

@implementation _SimpleJSONBicycletteCity

- (NSArray*) stationAttributesArraysFromData:(NSData*)data
{
    NSError * error;
    id res = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(!res)
        NSLog(@"Error parsing JSON in %@ : %@",self,error);
    return res;
}

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
    
    for (NSDictionary * attributeDict in json) {
        Station * station = [oldStations firstObjectWithValue:attributeDict[@"id"] forKeyPath:StationAttributes.number];
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
        station.status_totalValue = station.status_freeValue + station.status_availableValue;
        station.status_date = [NSDate date];
        
        station.region = region;
    }
}

@end


@implementation ChattanoogaBikeCity

#pragma mark Annotations

- (NSString *) title { return @"Bike Chattanooga"; }
- (NSString *) titleForStation:(Station *)station { return station.name; }

#pragma mark City Data Update

- (NSArray *) updateURLStrings { return @[@"http://www.bikechattanooga.com/stations/json"]; }
- (BOOL) hasRegions { return NO; }

- (NSArray*) stationAttributesArraysFromData:(NSData*)data
{
    id json = [super stationAttributesArraysFromData:data];
    if([json isKindOfClass:[NSDictionary class]])
        return json[@"stationBeanList"];
    else
        return nil;
}

- (NSDictionary*) KVCMapping
{
    return @{@"id" : StationAttributes.number,
    @"landMark" : StationAttributes.name,
    @"latitude" : StationAttributes.latitude,
    @"longitude": StationAttributes.longitude,
    @"stAddress1": StationAttributes.address,
    @"availableDocks": StationAttributes.status_free,
    @"availableBikes": StationAttributes.status_available,
    };
}

@end
