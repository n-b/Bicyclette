//
//  CoreDataManager.m
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Visuamobile. All rights reserved.
//

#import "CoreDataManager.h"
#import "NSFileManager+StandardPaths.h"


/****************************************************************************/
#pragma mark Private Methods

@interface CoreDataManager ()
@property (nonatomic, retain) NSManagedObjectModel *mom;
@property (nonatomic, retain) NSPersistentStoreCoordinator *psc;
@property (nonatomic, retain) NSManagedObjectContext *moc;
@end

/****************************************************************************/
#pragma mark -

@implementation CoreDataManager
@synthesize mom, psc, moc;

/****************************************************************************/
#pragma mark Init

- (id) init
{
   return [self initWithModelName:NSStringFromClass([self class])];
}

- (id) initWithModelName:(NSString*)modelName
{
    self = [super init];
    if (self) {
        
        // Create mom
		mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:modelName ofType:@"mom"]]]; 
        
        // Create psc
		psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.mom];
		NSError *error = nil;
		NSURL *storeURL = [NSURL fileURLWithPath: [[NSFileManager documentsDirectory] stringByAppendingPathComponent:[modelName stringByAppendingPathExtension:@"sqlite"]]];
        
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"DebugRemoveStore"])
        {
			NSLog(@"Removing data store");
			[[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
            //			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DebugRemoveStore"];
        }
        
		if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        {
			NSLog(@"Unresolved error when opening store %@, %@", error, [error userInfo]);
			if( error.code == NSPersistentStoreIncompatibleVersionHashError )
            {
				NSLog(@"trying to remove the existing db");
				[[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
				[psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];	
            }
			else
				abort();
        }
		
        // Create moc
		moc = [NSManagedObjectContext new];
		[moc setPersistentStoreCoordinator:self.psc];
		[moc setUndoManager:nil];
        
    }
    return self;
}

- (void)dealloc {
    self.mom = nil;
	self.psc = nil;
	self.moc = nil;
    [super dealloc];
}

/****************************************************************************/
#pragma mark -

- (void) save
{
	NSError * error;
	BOOL success = [self.moc save:&error];
	if(!success)
		NSLog(@"save failed : %@ %@",error, [error userInfo]);
}

@end
