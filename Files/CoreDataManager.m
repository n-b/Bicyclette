//
//  CoreDataManager.m
//
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright (c) 2011-2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CoreDataManager.h"
#import "NSError+MultipleErrorsCombined.h"
#import <objc/runtime.h>
#import "NSManagedObjectContext+ValidateDeleteAndSave.h"


/****************************************************************************/
#pragma mark Private Methods

@interface CoreDataManager ()
@property NSManagedObjectModel *mom;
@property NSPersistentStoreCoordinator *psc;
@property NSManagedObjectContext *moc;
@property NSOperationQueue *backgroundQueue;
@end

@interface NSManagedObjectContext (AssociatedManager_Private)
@property (nonatomic, retain, readwrite) CoreDataManager * coreDataManager;
@end

/****************************************************************************/
#pragma mark -

@implementation CoreDataManager

/****************************************************************************/
#pragma mark Init

- (id) init
{
    return [self initWithModelName:NSStringFromClass([self class])];
}

- (id) initWithModelName:(NSString*)modelName
{
    NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *storeURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:[modelName stringByAppendingPathExtension:@"coredata"]]];
    return [self initWithModelName:modelName storeURL:storeURL];
}

- (id) initWithModelName:(NSString*)modelName storeURL:(NSURL*)storeURL
{
    return [self initWithModelName:modelName storeURL:storeURL storeType:NSSQLiteStoreType];
}

- (id) initWithModelName:(NSString*)modelName storeURL:(NSURL*)storeURL storeType:(NSString*)storeType
{
    self = [super init];
    if (self) {
        
        // Create mom. Look for mom and momd variants.
        NSBundle * classBundle = [NSBundle bundleForClass:[self class]];
        NSURL * momURL = [classBundle URLForResource:modelName withExtension:@"mom"];
        if(nil==momURL)
            momURL = [classBundle URLForResource:modelName withExtension:@"momd"];
        if(nil==momURL)
            return nil;
		self.mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
        
        // Create psc
		self.psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.mom];
		NSError *error = nil;
        
        // Copy embedded store if we don't already have a store in the final location.
        if( ![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]])
            [self copyBundledStoreIfAvailableToURL:storeURL];

        // Add Persistent Store
		if (![self.psc addPersistentStoreWithType:storeType configuration:nil URL:storeURL
                                          options:nil error:&error])
        {
			if( error.code == NSPersistentStoreIncompatibleVersionHashError )
            {
                // This happens a lot during development. Just dump the old store and create a new one.
				NSLog(@"Incompatible data store. Trying to remove the existing db");
				[[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
                error = nil;
                
                // Copy embedded store instead of the incompatible one.
                [self copyBundledStoreIfAvailableToURL:storeURL];

                // Retry
				[self.psc addPersistentStoreWithType:storeType configuration:nil URL:storeURL options:nil error:&error];
            }
			
            if (error)
            {
                NSLog(@"Unresolved error when opening store %@, %@", error, [error userInfo]);
                // shit.
				abort();
            }
        }
		
        // Create update queue
        self.backgroundQueue = [NSOperationQueue new];
        self.backgroundQueue.maxConcurrentOperationCount = 1;
        
        // Create main moc
        self.moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
        self.moc.persistentStoreCoordinator = self.psc;

        self.moc.coreDataManager = self;
    }
    return self;
}

- (void) copyBundledStoreIfAvailableToURL:(NSURL*)storeURL
{
    NSString * storeName = [[storeURL.path lastPathComponent] stringByDeletingPathExtension];
    NSURL * embeddedStoreURL = [[NSBundle mainBundle] URLForResource:storeName withExtension:@"sqlite"];
    if(embeddedStoreURL)
        [[NSFileManager defaultManager] copyItemAtURL:embeddedStoreURL toURL:storeURL error:NULL];
}

/******************************************************************************/
#pragma mark -

- (void) erase
{
    NSURL * storeURL = [[[self.psc persistentStores] lastObject] URL];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
    self.moc = nil;
    [self.backgroundQueue cancelAllOperations];
    self.backgroundQueue = nil;
    self.psc = nil;
}

/******************************************************************************/
#pragma mark -

- (void) performUpdates:(void(^)(NSManagedObjectContext* updateContext))updates
         saveCompletion:(void(^)(NSNotification* contextDidSaveNotification))completion
{
    // Perform the update in a background queue
    __block NSOperation * updateOperation = [NSBlockOperation blockOperationWithBlock:^
     {
         // Create the context
         NSManagedObjectContext * updateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
         updateContext.persistentStoreCoordinator = self.psc;
         updateContext.coreDataManager = self;

         // Observe save notification to forward to the completion block in the main queue.
         __block id observation =
         [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                           object:updateContext
                                                            queue:[NSOperationQueue mainQueue]
                                                       usingBlock:^(NSNotification *note)
          {
              [[NSNotificationCenter defaultCenter] removeObserver:observation];

              // Check we're not cancelled
              if(updateOperation.isCancelled) return ;

              // Merge changes
              [self.moc mergeChangesFromContextDidSaveNotification:note];

              // Call completion
              completion(note);
          }];
         
         // Call the update block
         updates(updateContext);
         
         // Check we're not cancelled
         if(updateOperation.isCancelled) return ;
         
         // Validate, Delete, Save
         NSArray * deletedObjects;
         NSError * finalSaveError;
         __unused BOOL didSave = [updateContext saveAndDeleteInvalidObjects:&deletedObjects finalSaveError:&finalSaveError];
         // Do not handle save errors, we handle invalid objects and other errors are programmer errors.
         NSAssert(didSave || updateOperation.isCancelled,@"Failed to save :%@",finalSaveError);
     }];
                                     
    [self.backgroundQueue addOperation:updateOperation];
}

@end

/****************************************************************************/
#pragma mark -

@implementation NSManagedObjectContext (AssociatedManager)
static char kCoreDataManager_associatedManagerKey;

- (void) setCoreDataManager:(CoreDataManager*)coreDataManager
{
    objc_setAssociatedObject(self, &kCoreDataManager_associatedManagerKey, coreDataManager, OBJC_ASSOCIATION_RETAIN);
}

- (CoreDataManager*)coreDataManager
{
    return objc_getAssociatedObject(self, &kCoreDataManager_associatedManagerKey);
}
@end
