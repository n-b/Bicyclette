//
//  LaRochelleYeloCity.m
//  Bicyclette
//
//  Created by Nicolas on 18/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "LaRochelleYeloCity.h"
#import "BicycletteCity.mogenerated.h"
#import "CollectionsAdditions.h"
#import "NSObject+KVCMapping.h"
#import "NSStringAdditions.h"

@interface LaRochelleYeloCity () <NSXMLParserDelegate>
@end

@implementation LaRochelleYeloCity

#pragma mark Annotations

- (NSString *) title { return @"Yélo"; };
- (NSString *) titleForStation:(Station *)station { return station.name; };

#pragma mark City Data Update

- (BOOL) hasRegions { return NO; }
- (NSArray *)updateURLStrings { return @[ @"http://www.rtcr.fr/ct_93_297__Carte_du_libre_service_velos.html" ]; };


- (NSDictionary*) KVCMapping
{
    return @{@"num": StationAttributes.number,
             @"lat" : StationAttributes.latitude,
             @"lon": StationAttributes.longitude,
             @"name" : StationAttributes.name,
             @"bikeCount" : StationAttributes.status_available,
             @"lockCount" : StationAttributes.status_total,
             };
    
}

- (void)parseData:(NSData *)data fromURLString:(NSString *)urlString inContext:(NSManagedObjectContext *)context oldStations:(NSMutableArray *)oldStations
{
    // Create an anonymous region
    Region * region = [[Region fetchRegionWithNumber:context number:@"anonymousregion"] lastObject];
    if(region==nil)
    {
        region = [Region insertInManagedObjectContext:context];
        region.number = @"anonymousregion";
        region.name = @"anonymousregion";
    }

    
    NSString * string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSScanner * scanner = [NSScanner scannerWithString:string];
    NSString * jsonText = nil;
    [scanner scanUpToString:@"<script type=\"text/javascript\">var markers = [{" intoString:nil];
    [scanner scanString:@"<script type=\"text/javascript\">var markers = [{" intoString:nil];
    [scanner scanUpToString:@"}]</script>" intoString:&jsonText];
    if([jsonText length])
    {
//        NSError * error;
//        id json = [NSJSONSerialization JSONObjectWithData:[jsonText dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        for (NSString * stationText in [jsonText componentsSeparatedByString:@"},{"]) {
            NSMutableDictionary * attributeDict = [NSMutableDictionary new];
            for (NSString * attr in [stationText componentsSeparatedByString:@","]) {
                NSArray * keyAndValue = [attr componentsSeparatedByString:@":"];
                if([keyAndValue count]==2)
                {
                    attributeDict[[keyAndValue[0] stringByTrimmingWhitespace]] = [[keyAndValue[1] stringByTrimmingWhitespace] stringByTrimmingQuotes];
                }
            }
            
            Station * station = [oldStations firstObjectWithValue:attributeDict[@"num"] forKeyPath:StationAttributes.number];
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
            
            station.status_freeValue = station.status_totalValue - station.status_availableValue;
            station.status_date = [NSDate date];

            station.region = region;

        }
    }
    
//    while ([scanner scanUpToString:@"<tr>" intoString:nil]) {
//        NSString * number, * name, * status;
//        NSInteger bikesCount, totalCount;
//        BOOL ok = YES;
//
//        ok &= [scanner scanUpToString:@"<td class='colNum'>" intoString:nil];
//        ok &= [scanner scanUpToString:@"</td>" intoString:&number];
//
//        ok &= [scanner scanUpToString:@"<td class='colName'>" intoString:nil];
//        ok &= [scanner scanUpToString:@"</td>" intoString:&name];
//
//        ok &= [scanner scanUpToString:@"<td class='colVelo'>" intoString:nil];
//        ok &= [scanner scanInteger:&bikesCount];
//        ok &= [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
//        ok &= [scanner scanInteger:&totalCount];
//        ok &= [scanner scanUpToString:@"</td>" intoString:&status];
//        
//        if(!ok) continue;
//
//        Station * station = [oldStations firstObjectWithValue:number forKeyPath:StationAttributes.number];
//        if(station)
//        {
//            // found existing
//            [oldStations removeObject:station];
//        }
//        else
//        {
//            if(oldStations.count)
//                NSLog(@"Note : new station found after update : %@", number);
//            station = [Station insertInManagedObjectContext:context];
//        }
//        
//        // Set Values
//        station.number = number;
//        station.name = name;
//        station.status_availableValue = bikesCount;
//        station.status_totalValue = totalCount;
//        station.status_freeValue = totalCount - bikesCount;
//                
//        // Set Station
//        station.region = region;
//    };
    
    
}

@end
