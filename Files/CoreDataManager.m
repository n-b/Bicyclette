//
//  CoreDataManager.m
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "CoreDataManager.h"
#import "NSFileManager+StandardPaths.h"
#import "NSError+MultipleErrorsCombined.h"
#import <objc/runtime.h>


/****************************************************************************/
#pragma mark Private Methods

NSString * const BicycletteErrorDomain = @"BicycletteErrorDomain";

@interface CoreDataManager ()
@property NSManagedObjectModel *mom;
@property NSPersistentStoreCoordinator *psc;
@property NSManagedObjectContext *moc;
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
    NSURL *storeURL = [NSURL fileURLWithPath:[[NSFileManager documentsDirectory] stringByAppendingPathComponent:[modelName stringByAppendingPathExtension:@"sqlite"]]];
    return [self initWithModelName:modelName storeURL:storeURL];
}

- (id) initWithModelName:(NSString*)modelName storeURL:(NSURL*)storeURL
{
    self = [super init];
    if (self) {
        
        // Create mom
		self.mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:modelName ofType:@"mom"]]]; 
        
        // Create psc
		self.psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.mom];
		NSError *error = nil;
        
        // Debug
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"DebugRemoveStore"])
        {
			NSLog(@"Removing data store");
			[[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
        }
        
        // Copy embedded store, if we don't already have a store in the final location, and there's one in the app bundle.
        if( ![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]])
        {
            NSString * storeName = [[storeURL.path lastPathComponent] stringByDeletingPathExtension];
            NSURL * embeddedStoreURL = [[NSBundle mainBundle] URLForResource:storeName withExtension:@"sqlite"];
            if(embeddedStoreURL)
                [[NSFileManager defaultManager] copyItemAtURL:embeddedStoreURL toURL:storeURL error:NULL];
        }
        
        // Create PSC
		if (![self.psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        {
			NSLog(@"Unresolved error when opening store %@, %@", error, [error userInfo]);
			if( error.code == NSPersistentStoreIncompatibleVersionHashError )
            {
                // This happens a lot during development. Just dump the old store and create a new one.
				NSLog(@"trying to remove the existing db");
				[[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
				[self.psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];	
            }
			else
                // shit.
				abort();
        }
		
        // Create moc
        self.moc = [NSManagedObjectContext new];
		self.moc.persistentStoreCoordinator = self.psc;
		self.moc.undoManager = nil;
        
        self.moc.coreDataManager = self;
    }
    return self;
}


/****************************************************************************/
#pragma mark -

- (void) setNeedsSave
{
    NSTimeInterval delay = [[NSUserDefaults standardUserDefaults] doubleForKey:@"ModelSaveDelay"];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(save:) object:nil];
    [self performSelector:@selector(save:) withObject:nil afterDelay:delay];
}

- (BOOL) save:(NSError**)saveError
{
    return [self.moc save:saveError];
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
