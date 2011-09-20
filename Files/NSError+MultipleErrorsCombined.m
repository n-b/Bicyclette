//
//  NSError+MultipleErrorsCombined.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 18/09/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "NSError+MultipleErrorsCombined.h"

@implementation NSError (MultipleErrorsCombined)

+ (NSError *) errorFromOriginalError:(NSError *)originalError error:(NSError *)secondError
{
    if(originalError==nil)
        return secondError;
    if (secondError==nil)
        return originalError;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSMutableArray *errors = [NSMutableArray arrayWithObject:secondError];
    
    if ([originalError code] == NSValidationMultipleErrorsError) {
        // If the original error was already a compound, get the underlying errors
        [userInfo addEntriesFromDictionary:[originalError userInfo]];
        [errors addObjectsFromArray:[userInfo objectForKey:NSDetailedErrorsKey]];
    }
    else {
        // Otherwise just add it. 
        [errors addObject:originalError];
    }
    
    [userInfo setObject:errors forKey:NSDetailedErrorsKey];
    
    return [self errorWithDomain:NSCocoaErrorDomain code:NSValidationMultipleErrorsError userInfo:userInfo];
}

- (NSArray *) underlyingErrors
{
    if (self.code==NSValidationMultipleErrorsError)
        return [self.userInfo objectForKey:NSDetailedErrorsKey];
    else
        return [NSArray arrayWithObject:self];
}

@end
