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

@property (readonly) CLLocationCoordinate2D coordinate;

- (void) update;

#if TARGET_OS_IPHONE
@property (nonatomic, readonly) MKCoordinateRegion regionContainingData;
- (NSArray*) stationsWithinRegion:(MKCoordinateRegion)region;
- (NSArray*) radars;
#endif
- (Station*) stationWithNumber:(NSString*)number;

@property (readonly) NSDictionary* serviceInfo;
@property (readonly) CLRegion * hardcodedLimits;
@property (readonly) NSDictionary* stationsPatchs;
@end

/****************************************************************************/
#pragma mark -

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
#pragma mark Reimplemented

@protocol BicycletteCityURLs <NSObject>
- (NSString*) updateURLString;
@optional
- (NSString*) detailsURLStringForStation:(Station*)station;
@end

@protocol BicycletteCityParsing <NSObject>
- (BOOL) hasRegions;
- (void) parseData:(NSData*)data;
@end

@protocol BicycletteCityAnnotations <NSObject>
- (NSString*)title;
- (NSString*)titleForStation:(Station*)region;
@optional
- (NSString*)titleForRegion:(Region*)region;
- (NSString*)subtitleForRegion:(Region*)region;
@end

/****************************************************************************/
#pragma mark -

// Obtain the City from a ManagedObject.
@interface NSManagedObject (AssociatedCity)
- (BicycletteCity *) city;
@end

@interface BicycletteCity (Subclasses) <BicycletteCityURLs, BicycletteCityAnnotations, BicycletteCityParsing>
@end
