//
//  NSManagedObjectContext+ValidateDeleteAndSave.m
//
//
//  Created by Nicolas on 22/10/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "NSManagedObjectContext+ValidateDeleteAndSave.h"
#import "NSError+MultipleErrorsCombined.h"

NSString * const kValidateDeleteAndSaveManagedObjectContextErrorDomain = @"ValidateDeleteAndSaveManagedObjectContextErrorDomain";

@implementation NSManagedObjectContext (ValidateDeleteAndSave)

/******************************************************************************/
#pragma mark -

- (BOOL) saveAndDeleteInvalidObjects:(NSArray**)deletedObjectsErrors_ finalSaveError:(NSError**)saveError_
{
    // Saving works like this :
    // Individual NSManagedObject classes implement validation checks triggered at insert/update,
    // and will refuse to be saved if an error is encountered.
    //
    // The idea is to delete any faulty object, and reattempt the save.
    //
    // Additionally, the model defines cascade delete rules, so that the whole object tree under e.g. a PNR
    // will be deleted if the PNR doesn't pass validation.
    BOOL didSave;
    BOOL didDeleteAFaultyObject;
    NSError * lSaveError;
    NSMutableArray * lDeletedObjectsErrors = [NSMutableArray new];
    do {
        didSave = [self save:&lSaveError];
        didDeleteAFaultyObject = NO;
        if(didSave == NO)
        {
            for (NSError * error in [lSaveError underlyingErrors]) {
                BOOL canDelete = NO;
                if([error.domain isEqualToString:NSCocoaErrorDomain])
                    canDelete = (error.code == NSManagedObjectValidationError ||
                                 error.code == NSValidationMissingMandatoryPropertyError ||
                                 error.code == NSValidationRelationshipLacksMinimumCountError ||
                                 error.code == NSValidationRelationshipExceedsMaximumCountError);
                else if([error.domain isEqualToString:kValidateDeleteAndSaveManagedObjectContextErrorDomain])
                    canDelete = (error.code == NSManagedObjectValidationError);
                if (canDelete)
                {
                    NSManagedObject * faultyObject = error.userInfo[NSValidationObjectErrorKey];
                    if(deletedObjectsErrors_)
                        [lDeletedObjectsErrors addObject:error];
                    [self deleteObject:faultyObject];
                    didDeleteAFaultyObject = YES;
                }
            }
        }
    } while (didSave==NO && didDeleteAFaultyObject==YES);
    
    if(didSave==NO)
        *saveError_ = lSaveError;
    
    if(deletedObjectsErrors_ && [lDeletedObjectsErrors count])
        *deletedObjectsErrors_ = [lDeletedObjectsErrors copy];
    
    return didSave;
}

@end

/******************************************************************************/
#pragma mark -

@implementation NSError (ValidateDeleteAndSave)

+ (instancetype) validationErrorWithObject:(NSManagedObject*)object key:(NSString*)validationKey;
{
    return [NSError errorWithDomain:kValidateDeleteAndSaveManagedObjectContextErrorDomain
                               code:NSManagedObjectValidationError
                           userInfo:(@{ NSValidationObjectErrorKey: object,
                                     NSValidationKeyErrorKey: validationKey})];
}

@end
