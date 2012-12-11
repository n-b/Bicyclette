//
//  NSManagedObjectContext+ValidateDeleteAndSave.h
//
//
//  Created by Nicolas on 22/10/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//


@interface NSManagedObjectContext (ValidateDeleteAndSave)
// Save, and if it fails, delete the invalid objects and retry.
- (BOOL) saveAndDeleteInvalidObjects:(NSArray**)deletedObjectsErrors_ finalSaveError:(NSError**)saveError_;
@end

// Easily create a validation error
@interface NSError (ValidateDeleteAndSave)
// Easily create a validation error
+ (instancetype) validationErrorWithObject:(NSManagedObject*)object key:(NSString*)validationKey;
@end
