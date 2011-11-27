//
//  NSError+MultipleErrorsCombined.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 18/09/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (MultipleErrorsCombined)
// Helper method to create CoreData NSValidationMultipleErrorsError.
// Either parameter can be nil.
// If the originalError is already a NSValidationMultipleErrorsError, the secondError is combined.
+ (NSError *) errorFromOriginalError:(NSError *)originalError error:(NSError *)secondError;


// returns the array of underlying errors (the NSDetailedErrors of the userInfo) is the recever is a NSValidationMultipleErrorsError.
// otherwise, just make up a new NSArray containing the receiver.
//
- (NSArray *) underlyingErrors;
@end
