//
//  BicycletteCity+Update.h
//  Bicyclette
//
//  Created by Nicolas on 12/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"
#import "DataUpdater.h"

@interface BicycletteCity (Update)  <DataUpdaterDelegate>

- (NSArray *) updateURLStrings;
- (NSString*) detailsURLStringForStation:(Station*)station_;
+ (BOOL) canUpdateIndividualStations; // returns yes if stationStatusParsingClass is implemented

// Data Updates
- (void) update;

// Parsing
- (NSString*) stationNumberFromStationValues:(NSDictionary*)values; // override if necessary
- (void) insertStationWithAttributes:(NSDictionary*)stationAttributes;// Call from subclass during parsing
- (void) setStation:(Station*)station attributes:(NSDictionary*)stationAttributes;


@end

/****************************************************************************/
#pragma mark - Methods to be reimplementend by concrete subclasses

@class RegionInfo;
@protocol BicycletteCity

// City Data Updates
@required
- (void) parseData:(NSData*)data;
- (NSDictionary*) KVCMapping;

// Wether City has regions
@optional
- (RegionInfo*) regionInfoFromStation:(Station*)station
                               values:(NSDictionary*)values
                               patchs:(NSDictionary*)patchs
                           requestURL:(NSString*)urlString;

// Stations Individual Data Updates
@optional
- (Class) stationStatusParsingClass;

@end

// Allow me to use method implemented in subclasses
@interface BicycletteCity (BicycletteCity) <BicycletteCity>
@end

#pragma mark - RegionInfo

@interface RegionInfo : NSObject // Just a struct, actually
+ (instancetype) infoWithName:(NSString*)name number:(NSString*)number;
@property NSString * number;
@property NSString * name;
@end
