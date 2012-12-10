//
//  BicycletteCity.h
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "CoreDataManager.h"

@class Station, Region, Radar;
@class LocalUpdateQueue;

#if TARGET_OS_IPHONE
@interface BicycletteCity : CoreDataManager <MKAnnotation>
#else
@interface BicycletteCity : CoreDataManager
#endif

- (NSString *) name;

- (void) update;

@property (readonly) CLLocationCoordinate2D coordinate;

#if TARGET_OS_IPHONE
@property (nonatomic, readonly) MKCoordinateRegion regionContainingData;
- (NSArray*) stationsWithinRegion:(MKCoordinateRegion)region;
#endif

- (Station*) stationWithNumber:(NSString*)number;


@property (nonatomic, readonly) CLRegion * hardcodedLimits;
@property (readonly) NSString * stationDetailsURL;
@property (readonly) NSDictionary* stationsPatchs;
@end

/****************************************************************************/
#pragma mark -

// Obtain the City from an managedobject.
@interface NSManagedObject (AssociatedCity)
- (BicycletteCity *) city;
@end

/****************************************************************************/
#pragma mark -

extern const struct BicycletteCityNotifications {
	__unsafe_unretained NSString * canRequestLocation;
	__unsafe_unretained NSString * citySelected;
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
#pragma mark Reimplemented

@interface RegionInfo : NSObject
@property NSString * number;
@property NSString * name;
@end

@protocol BicycletteCity <NSObject>
- (RegionInfo*) regionInfoFromStation:(Station*)station patchs:(NSDictionary*)patchs;
- (NSString*)titleForRegion:(Region*)region;
- (NSString*)subtitleForRegion:(Region*)region;
- (NSString*)titleForStation:(Station*)region;
@end

@interface BicycletteCity (Reimplement) <BicycletteCity>
@end
