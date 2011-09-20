//
//  CoreDataManager.h
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Visuamobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const BicycletteErrorDomain;

// Core Data Standard Machinery
@interface CoreDataManager : NSObject

- (id) init; // calls initWithModelName:NSStringFromClass([self class])
- (id) initWithModelName:(NSString*)modelName;

@property (readonly, nonatomic, retain) NSManagedObjectContext *moc;

- (void) save;

@end


// reverse link to obtain the CoreDataManager from a moc, for example in the objects implementation.
@interface NSManagedObjectContext (AssociatedManager)
@property (nonatomic, retain, readonly) CoreDataManager * coreDataManager;
@end