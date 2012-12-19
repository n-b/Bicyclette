//
//  NSStringAdditions.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/06/07.
//  Copyright 2007 Nicolas Bouilleaud.
//

#import <Foundation/Foundation.h>


@interface NSString (NSStringAdditions)

- (NSString*) stringByDeletingPrefix:(NSString*) prefix;

- (NSString*) stringStartingAtComponent:(NSUInteger)start usingSeparator:(NSString*)separator;
- (NSString*) stringByTrimmingZeros;
- (NSString*) stringByTrimmingWhitespace;
- (NSString*) stringByTrimmingQuotes;
- (NSString*) capitalizedStringWithCurrentLocale;

@end
