//
//  BicycletteCity.h
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "CoreDataManager.h"
#import "DataUpdater.h"
#import "LocalUpdateQueue.h"
#import "BicycletteCity.mogenerated.h"

void BicycletteCitySetStoresDirectory(NSString* directory);
void BicycletteCitySetSaveStationsWithNoIndividualStatonUpdates(BOOL save);

/****************************************************************************/
#pragma mark - Semi-Abstract superclass.

@interface BicycletteCity : CoreDataManager <Locatable
#if TARGET_OS_IPHONE
,MKAnnotation
#endif
>
{
    void(^_updateCompletionBlock)(NSError*) ;
    NSManagedObjectContext * _parsing_context;
    NSMutableArray * _parsing_oldStations;
    NSMutableDictionary * _parsing_regionsByNumber;
    NSString * _parsing_urlString;
}

// initialization
+ (NSArray*) allCities;
+ (instancetype) cityWithServiceInfo:(NSDictionary*)serviceInfo;

// General properties
- (NSDictionary *) serviceInfo;
- (NSString *) cityName;
- (NSString *) serviceName;
- (NSDictionary*) patches;
- (NSDictionary*) prefs;
- (id) prefForKey:(NSString*)key; // Fallback to NSUserDefaults
- (CLRegion *) knownRegion;
- (CLRegion *) regionContainingData;
- (CLLocation *) location; // Locatable
- (CLLocationDistance) radius;  // Locatable
- (CLLocationCoordinate2D) coordinate; // MKAnnotation
- (BOOL) hasRegions; // returns yes if regionInfoFromStation: is implemented

// Annotations - override if necessary
- (NSString*) title;
- (NSString*) titleForStation:(Station*)station;
- (NSString *) subtitleForStation:(Station *)station;
- (NSString*) titleForRegion:(Region*)region;
- (NSString*) subtitleForRegion:(Region*)region;

// Fetch requests
- (Station*) stationWithNumber:(NSString*)number;
#if TARGET_OS_IPHONE
- (NSArray*) radars;
- (NSArray*) stationsWithinRegion:(MKCoordinateRegion)region;
#endif

@property DataUpdater * updater;

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

// Obtain the City from any Station, Region, or Radar.
@interface NSManagedObject (BicycletteCity)
- (BicycletteCity *) city;
@end

