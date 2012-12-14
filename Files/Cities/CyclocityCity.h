//
//  CyclocityCity.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"

// Common code for all Cyclocity systems (except Velov)
@interface _CyclocityCity : _BicycletteCity
- (BOOL) hasRegions;
- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations;

- (NSString*) titleForStation:(Station*)station;
@end


// Cities with multiple Regions
@class RegionInfo;
@protocol CyclocityCity <BicycletteCity>
@optional
- (RegionInfo*) regionInfoFromStation:(Station*)station patchs:(NSDictionary*)patchs;
@end

@interface RegionInfo : NSObject // Just a struct, actually
@property NSString * number;
@property NSString * name;
@end
