//
//  NSFileManager+StandardPaths.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "NSFileManager+StandardPaths.h"

@implementation NSFileManager (StandardPaths)
+ (NSString*) documentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
@end
