//
//  CompatibilityCategories.h
//  Bicyclette
//
//  Created by Nicolas on 21/08/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

/****************************************************************************/
#pragma mark -

// iOS 6 only method, when compiling wiht iOS 5 SDK
@interface NSString (CompatibilityCategories)
- (NSString *)capitalizedStringWithLocale:(NSLocale *)locale;
@end

