//
//  CoreDataManager.h
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright (c) 2011-2012 Nicolas Bouilleaud. All rights reserved.
//


// Core Data Standard Machinery
@interface CoreDataManager : NSObject

+ (NSString*) storePathForName:(NSString*)storeName;
- (id) initWithStoreName:(NSString*)storeName;

// Returns wether the store is loaded.
//
// Store is lazy loaded the first time it's used (when mainContext or performUpdates:saveCompletion: is called)
- (BOOL) isStoreLoaded;

// The main context, to be used on the main thread.
- (NSManagedObjectContext *) mainContext;

// Perform a batch of updates in the internal context, save it, merge the changes in the UI context, and notify when done.
// Uses the "ValidateDeleteAndSave" mechanism to save. If an object is invalid, it's deleted and saving is retried.
//
// The "updates" block may optionally return a debug dictionary, with keys the managedObjects and values debug information that will be logged
// if the object fails validation and is deleted
- (void) performUpdates:(void(^)(NSManagedObjectContext* updateContext))updates
         saveCompletion:(void(^)(NSNotification* contextDidSaveNotification))completion;

// Delete the store, the psc, and the moc. The receiver is effectively rendered useless.
- (void) erase;

@end

// reverse link to obtain the CoreDataManager from a moc, for example in the objects implementation.
@interface NSManagedObjectContext (AssociatedManager)
@property (nonatomic, retain, readonly) CoreDataManager * coreDataManager;
@end
