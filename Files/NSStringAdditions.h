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


@interface NSString (NSStringAdditions)

/*!
	@method stringByDeletingPrefix/Suffix:
*/
- (NSString*) stringByDeletingPrefix:(NSString*) prefix;

@end
