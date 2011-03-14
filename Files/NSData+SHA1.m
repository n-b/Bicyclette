//
//  NSData+SHA1.m
//  Bicyclette
//
//  Created by Nicolas on 14/03/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "NSData+SHA1.h"


#import "NSData+SHA1.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSData (SHA1)

#pragma mark -
#pragma mark SHA1 Hashing macros
#define HEComputeDigest(method)                                         \
CC_##method##_CTX ctx;                                              \
unsigned char digest[CC_##method##_DIGEST_LENGTH];                  \
CC_##method##_Init(&ctx);                                           \
CC_##method##_Update(&ctx, [self bytes], [self length]);            \
CC_##method##_Final(digest, &ctx);

#define HEComputeDigestNSData(method)                                   \
HEComputeDigest(method)                                             \
return [NSData dataWithBytes:digest length:CC_##method##_DIGEST_LENGTH];

#define HEComputeDigestNSString(method)                                 \
static char __HEHexDigits[] = "0123456789abcdef";                   \
unsigned char digestString[2*CC_##method##_DIGEST_LENGTH + 1];      \
unsigned int i;                                                     \
HEComputeDigest(method)                                             \
for(i=0; i<CC_##method##_DIGEST_LENGTH; i++) {                      \
digestString[2*i]   = __HEHexDigits[digest[i] >> 4];            \
digestString[2*i+1] = __HEHexDigits[digest[i] & 0x0f];          \
}                                                                   \
digestString[2*CC_##method##_DIGEST_LENGTH] = '\0';                 \
return [NSString stringWithCString:(char *)digestString encoding:NSASCIIStringEncoding];

#pragma mark -
#pragma mark SHA1 Hashing routines
- (NSData*) sha1Digest
{
	HEComputeDigestNSData(SHA1);
}
- (NSString*) sha1DigestString
{
	HEComputeDigestNSString(SHA1);
}

@end
