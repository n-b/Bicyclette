//
//  VelibDataManager.h
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/****************************************************************************/
#pragma mark -

@class Station;

@interface VelibDataManager : NSObject
- (id) init;
- (id) initWithVelibXML:(NSData*)xml;

@property (readonly, nonatomic, retain) NSManagedObjectModel *mom;
@property (readonly, nonatomic, retain) NSPersistentStoreCoordinator *psc;
@property (readonly, nonatomic, retain) NSManagedObjectContext *moc;

- (NSFetchRequest*) stations;
@end

