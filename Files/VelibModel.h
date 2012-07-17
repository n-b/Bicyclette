//
//  Velib.h
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "CoreDataManager.h"

#import <MapKit/MapKit.h>

#define kVelibStationsListURL		@"http://www.velib.paris.fr/service/carto"
#define kVelibStationsStatusURL		@"http://www.velib.paris.fr/service/stationdetails/paris/"

/****************************************************************************/
#pragma mark -

@class Radar;
@class RadarUpdateQueue;

@interface VelibModel : CoreDataManager

- (NSString *) name;

- (void) update;

@property (readonly, nonatomic) MKCoordinateRegion regionContainingData;

@property (readonly, nonatomic) Radar * userLocationRadar;
@property (readonly, nonatomic) Radar * screenCenterRadar;

@property (readonly) RadarUpdateQueue * updaterQueue;

@property (readonly, nonatomic, strong) CLRegion * hardcodedLimits;
@end


// reverse link to obtain the CoreDataManager from a moc, for example in the objects implementation.
@interface NSManagedObjectContext (AssociatedModel)
@property (nonatomic, retain, readonly) VelibModel * model;
@end


extern const struct VelibModelNotifications {
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
} VelibModelNotifications;
