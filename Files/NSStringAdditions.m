//
//  NSStringAdditions.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/06/07.
//  Copyright 2007 Nicolas Bouilleaud.
//
//	Miscellaneous NSString additions, either custom or made from various places
//	See http://svn.gna.org/viewcvs/gnustep/libs/base/trunk/Source/Additions/GSCategories.m
//	See http://www.cocoadev.com/index.pl?NSStringCategory
//

#import "NSStringAdditions.h"


@implementation NSString (LCNSStringAdditions)

- (BOOL)containsString:(NSString *)aString
{
    return [self containsString:aString ignoringCase:NO];
}

- (BOOL)containsString:(NSString *)aString ignoringCase:(BOOL)flag
{
    unsigned mask = (flag ? NSCaseInsensitiveSearch : 0);
    NSRange range = [self rangeOfString:aString options:mask];
    return (range.length > 0);
}

#pragma mark -

- (NSString*) stringByDeletingPrefix:(NSString*) prefix
{
	if( ![self hasPrefix:prefix] )
		return self;
	return [self substringFromIndex:[prefix length]];
}

- (NSString*) stringByDeletingSuffix:(NSString*) suffix
{
	if( ![self hasSuffix:suffix] )
		return self;
	return [self substringToIndex: ([self length] - [suffix length])];
}

- (NSString*) stringByDeletingPrefixAndSuffix:(NSString*) prefixsuffix
{
	return [[self stringByDeletingPrefix:prefixsuffix] stringByDeletingSuffix:prefixsuffix];
}

#pragma mark -

+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    return [[self alloc] initWithData:data encoding:encoding];
}

+ (NSString *)stringWithBytes:(const void *)bytes length:(unsigned)length encoding:(NSStringEncoding)encoding
{
	return [[self alloc] initWithBytes:bytes length:length encoding:encoding];
}

#pragma mark -

- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet*)characterSet
{
	NSScanner*       cleanerScanner = [NSScanner scannerWithString:self];
	NSMutableString* cleanString    = [NSMutableString stringWithCapacity:[self length]];
	
	while (![cleanerScanner isAtEnd])
	{
		NSString* stringFragment;
		if ([cleanerScanner scanUpToCharactersFromSet:characterSet intoString:&stringFragment])
			[cleanString appendString:stringFragment];
		
		[cleanerScanner scanCharactersFromSet:characterSet intoString:nil];
	}
	
	return cleanString;
}

@end
