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

    
    NSArray *errors = [[originalError underlyingErrors] arrayByAddingObjectsFromArray:[secondError underlyingErrors]];
    
    
    return [self errorWithDomain:NSCocoaErrorDomain 
                            code:NSValidationMultipleErrorsError 
                        userInfo:@{ NSDetailedErrorsKey : errors }];
}

- (NSArray *) underlyingErrors
{
    if (self.code==NSValidationMultipleErrorsError)
        return (self.userInfo)[NSDetailedErrorsKey];
    else
        return @[ self ];
}

@end
