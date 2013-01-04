//
//  _XMLCityWithStationDataInAttributes.h
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"

@interface _XMLCityWithStationDataInAttributes : _BicycletteCity
- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations;
- (BOOL) hasRegions;
@end

// To be implemented by subclasses
@class RegionInfo;
@protocol XMLCityWithStationDataInAttributes <BicycletteCity>
- (NSString*) stationElementName;
- (NSString*) stationNumberFromStationValues:(NSDictionary*)values;
- (NSDictionary*) KVCMapping;
@optional
- (RegionInfo*) regionInfoFromStation:(Station*)station values:(NSDictionary*)values patchs:(NSDictionary*)patchs requestURL:(NSString*)urlString;
@end

@interface RegionInfo : NSObject // Just a struct, actually
+ (instancetype) infoWithName:(NSString*)name number:(NSString*)number;
@property NSString * number;
@property NSString * name;
@end
