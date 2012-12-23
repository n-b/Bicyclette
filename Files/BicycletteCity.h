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

//
#pragma mark Semi-Abstract superclass.
@interface _BicycletteCity : CoreDataManager <Locatable>

#pragma mark initialization
+ (NSArray*) allCities;
+ (instancetype) cityWithServiceInfo:(NSDictionary*)serviceInfo;

#pragma mark General properties
- (NSDictionary *) serviceInfo;
- (NSString *) cityName;
- (NSString *) serviceName;
- (NSArray *) updateURLStrings;
- (CLRegion *) hardcodedLimits;
#if TARGET_OS_IPHONE
- (CLLocationCoordinate2D) coordinate;
- (MKCoordinateRegion) regionContainingData;
#endif

#pragma mark Fetch requests
- (Station*) stationWithNumber:(NSString*)number;
#if TARGET_OS_IPHONE
- (NSArray*) radars;
- (NSArray*) stationsWithinRegion:(MKCoordinateRegion)region;
#endif

#pragma mark Data Updates
- (void) update;
+ (BOOL) canUpdateIndividualStations;

#pragma mark Annotation
- (NSString*) title;
- (NSString*) titleForStation:(Station*)station; // returns station.name, override for custom behaviour

@end


//
// Methods to be reimplementend by concrete subclasses
@protocol BicycletteCity
#if TARGET_OS_IPHONE
							<MKAnnotation>
#endif

#pragma mark City Data Update
@required
- (BOOL) hasRegions;
- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations;

#pragma mark Stations Individual Data Updates
@optional
- (NSString*) detailsURLStringForStation:(Station*)station_;
- (void) parseData:(NSData *)data forStation:(Station *)station;

#pragma mark Annotations
@required
@optional
- (NSString*) titleForStation:(Station*)station;
- (NSString*) titleForRegion:(Region*)region;
- (NSString*) subtitleForRegion:(Region*)region;

@end

// BicycletteCity
// This class does not really exist. It serves as an abstract class that responds to all the <BicycletteCity> methods for the rest of the app.
@interface BicycletteCity : _BicycletteCity < BicycletteCity >
@end

// Obtain the City from any Station, Region, or Radar.
@interface NSManagedObject (BicycletteCity)
- (BicycletteCity *) city;
@end

//
#pragma mark Update Notifications
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
