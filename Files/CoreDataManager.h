//
//  CoreDataManager.h
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright (c) 2011-2012 Nicolas Bouilleaud. All rights reserved.
//


// Core Data Standard Machinery
@interface CoreDataManager : NSObject

- (id) init;									// default model name is NSStringFromClass([self class])
- (id) initWithModelName:(NSString*)modelName;	// default store url is ~/Documents/<modelName>.sqlite
- (id) initWithModelName:(NSString*)modelName storeURL:(NSURL*)storeURL;

// The main context, to be used on the main thread.
@property (readonly) NSManagedObjectContext *moc;

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
