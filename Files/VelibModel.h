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

@class Station;
@class DataUpdater;

@interface VelibModel : CoreDataManager

@property (nonatomic, strong, readonly) DataUpdater * updater;
@property (readonly) BOOL updatingXML;

@property (readonly, nonatomic) MKCoordinateRegion regionContainingData;

@property (readonly, nonatomic, strong) CLRegion * hardcodedLimits;
@end


// reverse link to obtain the CoreDataManager from a moc, for example in the objects implementation.
@interface NSManagedObjectContext (AssociatedModel)
@property (nonatomic, retain, readonly) VelibModel * model;
@end