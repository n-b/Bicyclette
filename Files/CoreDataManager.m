//
//  CoreDataManager.m
//
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright (c) 2011-2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CoreDataManager.h"
#import "NSError+MultipleErrorsCombined.h"
#import "NSManagedObjectContext+ValidateDeleteAndSave.h"


/****************************************************************************/
#pragma mark Private Methods

@interface CoreDataManager ()
@end

@interface NSManagedObjectContext (AssociatedManager_Private)
@property (nonatomic, retain, readwrite) CoreDataManager * coreDataManager;
@end

/****************************************************************************/
#pragma mark -

@implementation CoreDataManager
{
    NSString * _storeName;
    NSManagedObjectModel * _mom;
    NSPersistentStoreCoordinator * _psc;
    NSManagedObjectContext *_mainContext;
    NSOperationQueue * _backgroundQueue;
}

/****************************************************************************/
#pragma mark Init

- (NSString*) storePathForName:(NSString*)storeName
{
    NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [documentsDirectory stringByAppendingPathComponent:[storeName stringByAppendingPathExtension:@"coredata"]];
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id) initWithStoreName:(NSString*)storeName_
{
    self = [super init];
    if (self) {
        _storeName = storeName_;
    }
    return self;
}

- (BOOL) isStoreLoaded
{
    return nil!=_mainContext;
}

- (void) loadStoreIfNeeded
{
    NSAssert([NSThread currentThread] == [NSThread mainThread], nil);
    
    if(nil==_mainContext)
    {
        // Create mom. Look for mom and momd variants.
        NSURL * momURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"BicycletteCity" withExtension:@"mom"];
		_mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
        
        // Create psc
		_psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_mom];
		NSError *error = nil;
        
        NSString * storePath = [self storePathForName:_storeName];
        if(storePath)
        {
            NSURL *storeURL = [NSURL fileURLWithPath:storePath];
            // Copy embedded store if we don't already have a store in the final location.
            if( ![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]])
                [self copyBundledStoreIfAvailableToURL:storeURL];
            
            // Add Persistent Store
            if (![_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL
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
                    [_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
                }
                
                if (error)
                {
                    NSLog(@"Unresolved error when opening store %@, %@", error, [error userInfo]);
                    // shit.
                    abort();
                }
            }
        }
        else
        {
            // Create an inmemory store
            [_psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];
            if (error)
            {
                NSLog(@"Unresolved error when creating memory store %@, %@", error, [error userInfo]);
                // shit.
                abort();
            }
        }
        
        // Create update queue
        _backgroundQueue = [NSOperationQueue new];
        _backgroundQueue.maxConcurrentOperationCount = 1;
        
        // Create main moc
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
        _mainContext.persistentStoreCoordinator = _psc;
        
        _mainContext.coreDataManager = self;
    }
}

- (NSManagedObjectContext *) mainContext
{
    [self loadStoreIfNeeded];
    return _mainContext;
}

- (void) copyBundledStoreIfAvailableToURL:(NSURL*)storeURL
{
    NSString * storeName = [storeURL.path lastPathComponent];
    NSURL * embeddedStoreURL = [[NSBundle mainBundle] URLForResource:[storeName stringByDeletingPathExtension] withExtension:[storeName pathExtension]];
    if(embeddedStoreURL)
        [[NSFileManager defaultManager] copyItemAtURL:embeddedStoreURL toURL:storeURL error:NULL];
}

/******************************************************************************/
#pragma mark -

- (void) erase
{
    NSURL * storeURL = [[[_psc persistentStores] lastObject] URL];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
    _mainContext = nil;
    [_backgroundQueue cancelAllOperations];
    _backgroundQueue = nil;
    _psc = nil;
    _mom = nil;
}

/******************************************************************************/
#pragma mark -

- (void) performUpdates:(void(^)(NSManagedObjectContext* updateContext))updates
         saveCompletion:(void(^)(NSNotification* contextDidSaveNotification))completion
{
    [self loadStoreIfNeeded];
    
    // Perform the update in a background queue
    __block NSOperation * updateOperation = [NSBlockOperation blockOperationWithBlock:^
     {
         // Create the context
         NSManagedObjectContext * updateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
         updateContext.persistentStoreCoordinator = _psc;
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
              [_mainContext mergeChangesFromContextDidSaveNotification:note];

              // Call completion
              if(completion)
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
                                     
    [_backgroundQueue addOperation:updateOperation];
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
