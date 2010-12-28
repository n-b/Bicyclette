//
//  VelibDataManager.h
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

#define kVelibStationsListURL		@"http://www.velib.paris.fr/service/carto"
#define kVelibStationsStatusURL		@"http://www.velib.paris.fr/service/stationdetails/"

/****************************************************************************/
#pragma mark -

@class Station;

@interface VelibDataManager : NSObject

@property (readonly, nonatomic, retain) NSManagedObjectModel *mom;
@property (readonly, nonatomic, retain) NSPersistentStoreCoordinator *psc;
@property (readonly, nonatomic, retain) NSManagedObjectContext *moc;

@property (readonly) BOOL downloadingUpdate;
@property (readonly) BOOL updatingXML;

- (void) save;

@property (readonly, nonatomic) MKCoordinateRegion coordinateRegion;
@end

