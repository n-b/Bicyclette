//
//  CoreDataManager.h
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const BicycletteErrorDomain;
@protocol CoreDataManagerDelegate;

// Core Data Standard Machinery
@interface CoreDataManager : NSObject

- (id) init;									// default model name is NSStringFromClass([self class])
- (id) initWithModelName:(NSString*)modelName;	// default store url is ~/Documents/<modelName>.sqlite
- (id) initWithModelName:(NSString*)modelName storeURL:(NSURL*)storeURL;

@property (readonly) NSManagedObjectContext *moc;
@property (weak) id<CoreDataManagerDelegate> delegate; 

- (BOOL) save:(NSError**)saveError;

- (void) setNeedsSave; // Will save later
@end

// reverse link to obtain the CoreDataManager from a moc, for example in the objects implementation.
@interface NSManagedObjectContext (AssociatedManager)
@property (nonatomic, retain, readonly) CoreDataManager * coreDataManager;
@end
