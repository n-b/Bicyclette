//
//  CompatibilityCategories.h
//  Bicyclette
//
//  Created by Nicolas on 21/08/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

/****************************************************************************/
#pragma mark -

// http://petersteinberger.com/blog/2012/using-subscripting-with-Xcode-4_4-and-iOS-4_3/

// Add support for subscripting to the iOS 5 SDK.
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
@interface NSObject (PSPDFSubscriptingSupport)

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
- (id)objectForKeyedSubscript:(id)key;

@end
#endif


// iOS 6 only method, when compiling wiht iOS 5 SDK
@interface NSString (CompatibilityCategories)
- (NSString *)capitalizedStringWithLocale:(NSLocale *)locale;
@end

