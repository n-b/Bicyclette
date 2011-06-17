//
//  NSObject+KVCMapping.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 18/06/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "NSObject+KVCMapping.h"


@implementation NSObject (NSObject_KVCMapping)
- (void) setMappedValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
    NSDictionary * mapping = [[self class] performSelector:@selector(kvcMapping)];
    for (NSString * wantedKey in [keyedValues allKeys]) 
    {
        NSString * foundKey = [mapping objectForKey:wantedKey];
        if([foundKey length])
            [self setValue:[keyedValues objectForKey:wantedKey] forKey:foundKey];
#if DEBUG
        else
            NSLog(@"ignored key : %@ for class %@",wantedKey, [self class]);
#endif
    }
}
@end
