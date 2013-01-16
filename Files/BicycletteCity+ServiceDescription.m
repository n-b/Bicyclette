//
//  BicycletteCity+ServiceDescription.m
//  Bicyclette
//
//  Created by Nicolas on 12/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity+ServiceDescription.h"
#import "BicycletteCity+Update.h"

@implementation BicycletteCity (ServiceDescription)

#pragma mark Service Complete Description
- (NSMutableDictionary *) fullServiceInfo
{
    NSMutableDictionary * info = [self.serviceInfo mutableCopy];
    
    // Set real Region instead of hardcoded data
    if([self isStoreLoaded])
    {
        [info setObject:@(self.regionContainingData.center.latitude) forKey:@"latitude"];
        [info setObject:@(self.regionContainingData.center.longitude) forKey:@"longitude"];
        [info setObject:@(self.regionContainingData.radius) forKey:@"radius"];
    }
    
    // Add KVCMapping
    [info setObject:[self KVCMapping] forKey:@"KVCMapping"];
    
    // station parsing class
    if([self stationStatusParsingClass])
        [info setObject:NSStringFromClass([self stationStatusParsingClass]) forKey:@"station_status_parsing_class"];
    
    return info;
}

@end
