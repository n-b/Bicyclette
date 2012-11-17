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


@implementation NSString (NSStringAdditions)


#pragma mark -

- (NSString*) stringByDeletingPrefix:(NSString*) prefix
{
	if( ![self hasPrefix:prefix] )
		return self;
	return [self substringFromIndex:[prefix length]];
}

@end
