//
//  BicycletteCity.h
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "CoreDataManager.h"
#import "LocalUpdateQueue.h"
@class Station, Region, Radar;

void BicycletteCitySetStoresDirectory(NSString* directory);
void BicycletteCitySetSaveStationsWithNoIndividualStatonUpdates(BOOL save);

/****************************************************************************/
#pragma mark - Semi-Abstract superclass.
@interface _BicycletteCity : CoreDataManager <Locatable>

// initialization
+ (NSArray*) allCities;
+ (instancetype) cityWithServiceInfo:(NSDictionary*)serviceInfo;

// General properties
- (NSDictionary *) serviceInfo;
- (NSString *) cityName;
- (NSString *) serviceName;
- (NSArray *) updateURLStrings;
- (NSDictionary*) patches;
- (CLRegion *) hardcodedLimits;
- (CLRegion *) regionContainingData;
- (CLLocation *) location; // Locatable
- (CLLocationDistance) radius;  // Locatable
- (CLLocationCoordinate2D) coordinate; // MKAnnotation
- (BOOL) hasRegions; // returns yes if regionInfoFromStation: is implemented

// Fetch requests
- (Station*) stationWithNumber:(NSString*)number;
#if TARGET_OS_IPHONE
- (NSArray*) radars;
- (NSArray*) stationsWithinRegion:(MKCoordinateRegion)region;
#endif

// Data Updates
- (void) update;
+ (BOOL) canUpdateIndividualStations;

// Annotations
- (NSString*) title;

@end

/****************************************************************************/
#pragma mark - Methods to be reimplementend by concrete subclasses
@class RegionInfo;
@protocol BicycletteCity
#if TARGET_OS_IPHONE
							<MKAnnotation>
#endif

// Annotations
@optional
- (NSString*) titleForStation:(Station*)station;
- (NSString*) titleForRegion:(Region*)region;
- (NSString*) subtitleForRegion:(Region*)region;

// City Data Updates
@required
- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations;

// Wether City has regions
@optional
- (RegionInfo*) regionInfoFromStation:(Station*)station
                               values:(NSDictionary*)values
                               patchs:(NSDictionary*)patchs
                           requestURL:(NSString*)urlString;

// Stations Individual Data Updates
@optional
- (NSString*) detailsURLStringForStation:(Station*)station_;
- (void) parseData:(NSData *)data forStation:(Station *)station;

@end

@interface RegionInfo : NSObject // Just a struct, actually
+ (instancetype) infoWithName:(NSString*)name number:(NSString*)number;
@property NSString * number;
@property NSString * name;
@end

/****************************************************************************/
#pragma mark - Update Notifications
extern const struct BicycletteCityNotifications {
	__unsafe_unretained NSString * canRequestLocation;
	__unsafe_unretained NSString * updateBegan;
	__unsafe_unretained NSString * updateGotNewData;
	__unsafe_unretained NSString * updateSucceeded;
	__unsafe_unretained NSString * updateFailed;
    struct
    {
        __unsafe_unretained NSString * dataChanged;
        __unsafe_unretained NSString * saveErrors;
        __unsafe_unretained NSString * failureError;
    } keys;
} BicycletteCityNotifications;

/****************************************************************************/
#pragma mark - BicycletteCity
// This class does not really exist. It serves as an abstract class that responds to all the <BicycletteCity> methods for the rest of the app.
@interface BicycletteCity : _BicycletteCity < BicycletteCity >
@end

// Obtain the City from any Station, Region, or Radar.
@interface NSManagedObject (BicycletteCity)
- (BicycletteCity *) city;
@end

