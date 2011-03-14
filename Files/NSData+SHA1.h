//
//  NSData+SHA1.h
//  Bicyclette
//
//  Created by Nicolas on 14/03/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (SHA1)
- (NSData*) sha1Digest;
- (NSString*) sha1DigestString;
@end
