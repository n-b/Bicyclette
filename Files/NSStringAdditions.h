//
//  NSStringAdditions.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/06/07.
//  Copyright 2007 Nicolas Bouilleaud.
//
//	Miscellaneous NSString additions, either custom or made from various places
//	See http://svn.gna.org/viewcvs/gnustep/libs/base/trunk/Source/Additions/GSCategories.m
//	See http://www.cocoadev.com/index.pl?NSStringCategory
//

#import <Foundation/Foundation.h>


@interface NSString (LCNSStringAdditions)

/*!
	@method containsString:
*/
- (BOOL)containsString:(NSString *)aString;
- (BOOL)containsString:(NSString *)aString ignoringCase:(BOOL)flag;

/*!
	@method stringByDeletingPrefix/Suffix:
*/
- (NSString*) stringByDeletingPrefix:(NSString*) prefix;
- (NSString*) stringByDeletingSuffix:(NSString*) suffix;
- (NSString*) stringByDeletingPrefixAndSuffix:(NSString*) prefixsuffix;

/*!
	@method stringWithData:
*/
+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

/*!
	@method stringWithBytes:
*/
+ (NSString *)stringWithBytes:(const void *)bytes length:(unsigned)length encoding:(NSStringEncoding)encoding;


/*!
	@method stringByRemovingCharactersInSet:
 */
- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet*)characterSet;

/*!
	@method passwordStrength:
*/
- (float)passwordStrength;

@end