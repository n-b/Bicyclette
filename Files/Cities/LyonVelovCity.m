//
//  LyonVelovCity.m
//  Bicyclette
//
//  Created by Nicolas on 13/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "LyonVelovCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"
#import "CollectionsAdditions.h"
#import "NSObject+KVCMapping.h"

@implementation LyonVelovCity

- (NSArray*) updateURLStrings
{
    NSArray * zips = @[
                       @"69381",
                       @"69382",
                       @"69383",
                       @"69384",
                       @"69385",
                       @"69386",
                       @"69387",
                       @"69388",
                       @"69389",
                       ];

    NSMutableArray * urlStrings = [NSMutableArray new];
    for (NSString * zip in zips) {
        [urlStrings addObject:[NSString stringWithFormat:@"http://www.velov.grandlyon.com/velovmap/zhp/inc/StationsParArrondissement.php?arrondissement=%@",zip]];
    }
    return urlStrings;
}

- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.velov.grandlyon.com/velovmap/zhp/inc/DispoStationsParId.php?id=%@",station.number]; }
- (NSString*) title { return @"Vélo’v"; }

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

- (NSString*) titleForRegion:(Region*)region { return [NSString stringWithFormat:@"%@°",region.number]; }
- (NSString*) subtitleForRegion:(Region*)region { return @"arr."; }

- (BOOL) hasRegions
{
    return YES;
}

- (NSDictionary*) KVCMapping
{
    return @{
             @"infoStation": StationAttributes.address,
             @"nomStation": StationAttributes.name,
             @"numStation": StationAttributes.number,
             @"x": StationAttributes.latitude, // yes. x,y for lat,long. (not even x,y for long,lat !)
             @"y": StationAttributes.longitude,
             };
}

- (void) parseData:(NSData*)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations
{
    NSString * regionNumber = [urlString substringFromIndex:[urlString length]-1];
    // Create Region
    Region * region = [[Region fetchRegionWithNumber:context number:regionNumber] lastObject];
    if(region==nil)
    {
        region = [Region insertInManagedObjectContext:context];
        region.number = regionNumber;
        region.name = regionNumber;
    }

    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    for (NSDictionary * stationInfo in json[@"markers"])
    {
        // Find Existing Stations
        Station * station = [oldStations firstObjectWithValue:stationInfo[@"numStation"] forKeyPath:StationAttributes.number];
        if(station)
        {
            // found existing
            [oldStations removeObject:station];
        }
        else
        {
            if(oldStations.count)
                NSLog(@"Note : new station found after update : %@", stationInfo);
            station = [Station insertInManagedObjectContext:context];
        }
        
        // Set Values
        [station setValuesForKeysWithDictionary:stationInfo withMappingDictionary:[self KVCMapping]]; // Yay!
        
        station.region = region;
    }
}

@end
