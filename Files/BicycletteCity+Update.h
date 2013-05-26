//
//  BicycletteCity+Update.h
//  Bicyclette
//
//  Created by Nicolas on 12/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"
#import "DataUpdater.h"

@interface BicycletteCity (Update)  <DataUpdaterDelegate, LocalUpdatePoint>

- (NSArray *) updateURLStrings;
- (NSString*) detailsURLStringForStation:(Station*)station_;

- (NSDictionary*) KVCMapping;

- (Class) stationStatusParsingClass; // Default is nil
- (BOOL) canUpdateIndividualStations; // returns yes if stationStatusParsingClass is not nil

- (BOOL) canShowFreeSlots; // returns yes if either status_free or both status_total and status_available are in the KVCMapping

// Data Updates
- (void) updateWithCompletionBlock:(void(^)(NSError* error))completion;
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

// Wether City has regions
@optional
- (RegionInfo*) regionInfoFromStation:(Station*)station
                               values:(NSDictionary*)values
                               patchs:(NSDictionary*)patchs
                           requestURL:(NSString*)urlString;

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
