//
//  SimpleStationsListBicycletteCity.h
//  Bicyclette
//
//  Created by Nicolas on 21/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"

// Common code for webservices returning a flat list of stations attributes.
@interface _SimpleStationsListBicycletteCity : _BicycletteCity
// BicycletteCity protocol
- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations;
@end

// To be implemented by subclasses
@protocol SimpleStationsListBicycletteCity <BicycletteCity>
- (NSArray*) stationAttributesArraysFromData:(NSData*)data;
- (NSDictionary*) KVCMapping;
@end

// JSON
@interface _SimpleJSONStationsListBicycletteCity : _SimpleStationsListBicycletteCity
- (NSArray*) stationAttributesArraysFromData:(NSData*)data; // basic JSON deserialize
@end


@protocol SimpleJSONStationsListBicycletteCity <SimpleStationsListBicycletteCity>
@optional
- (NSString*) keyPathToStationsLists;
@end
