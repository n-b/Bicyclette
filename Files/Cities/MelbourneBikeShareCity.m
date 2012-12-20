//
//  MelbourneBikeShareCity.m
//  Bicyclette
//
//  Created by Nicolas on 20/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "MelbourneBikeShareCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"

@interface MelbourneBikeShareCity ()

@end


@implementation MelbourneBikeShareCity

#pragma mark Annotations

- (NSString *) title { return @"Bike Share"; }
- (NSString *) titleForStation:(Station *)station { return station.name; }

#pragma mark City Data Update

- (NSArray *) updateURLStrings { return @[@"http://www.melbournebikeshare.com.au/stationmap/data"]; }
- (BOOL) hasRegions { return NO; }

- (NSDictionary*) KVCMapping
{
    return @{@"id": StationAttributes.number,
             @"lat" : StationAttributes.latitude,
             @"long": StationAttributes.longitude,
             @"name" : StationAttributes.name,
             @"nbBikes" : StationAttributes.status_available,
             @"nbEmptyDocks" : StationAttributes.status_free,
             };
    
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

    // The JSON is invalid. Great.
    NSMutableString * str = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [str replaceOccurrencesOfString:@"\\x26" withString:@"&" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\\'" withString:@"'" options:0 range:NSMakeRange(0, [str length])];
    
    NSError * error;
    id json = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    

    if (nil==json) {
        NSLog(@"Error %@",error);
        return;
    }
    
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
