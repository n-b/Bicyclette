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
    
    if([self isStoreLoaded])
    {
        // Set real Region instead of hardcoded data
        CLCircularRegion * regionContainingData = self.regionContainingData;
        [info setObject:@(regionContainingData.center.latitude) forKey:@"latitude"];
        [info setObject:@(regionContainingData.center.longitude) forKey:@"longitude"];
        [info setObject:@(regionContainingData.radius) forKey:@"radius"];

        // Set MKCoordinateRegion
        MKCoordinateRegion mkRegionContainingData = self.mkRegionContainingData;
        if(mkRegionContainingData.center.latitude != 0){
            [info setObject:@(mkRegionContainingData.center.latitude) forKey:@"mkCoordinateRegionLatitude"];
            [info setObject:@(mkRegionContainingData.center.longitude) forKey:@"mkCoordinateRegionLongitude"];
            [info setObject:@(mkRegionContainingData.span.latitudeDelta) forKey:@"mkCoordinateRegionLatitudeDelta"];
            [info setObject:@(mkRegionContainingData.span.longitudeDelta) forKey:@"mkCoordinateRegionLongitudeDelta"];
        }
    }

    // Add KVCMapping (only if it was in the serviceInfo)
    if(self.serviceInfo[@"KVCMapping"]) {
        NSAssert([[self KVCMapping] isEqual:self.serviceInfo[@"KVCMapping"]], @"KVCMapping specified in serviceInfo but overridden");
        [info setObject:[self KVCMapping] forKey:@"KVCMapping"];
    }
    
    // station parsing class
    if([self stationStatusParsingClass])
        [info setObject:NSStringFromClass([self stationStatusParsingClass]) forKey:@"station_status_parsing_class"];
    
    
    return info;
}

@end
