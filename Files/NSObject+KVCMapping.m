//
//  NSObject+KVCMapping.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 18/06/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "NSObject+KVCMapping.h"


@implementation NSObject (NSObject_KVCMapping)

- (void) setValue:(id)value forMappedKey:(NSString*)wantedKey
{
    NSDictionary * mapping = [[self class] performSelector:@selector(kvcMapping)];
    NSString * mappedKey = [mapping objectForKey:wantedKey];
    if([mappedKey length])
        [self setValue:value forKey:mappedKey];
#if DEBUG
    else
        NSLog(@"ignored key : %@ for class %@",wantedKey, [self class]);
#endif
}

- (void) setValuesForMappedKeysWithDictionary:(NSDictionary *)keyedValues
{
    NSDictionary * mapping = [[self class] performSelector:@selector(kvcMapping)];
    for (NSString * wantedKey in [keyedValues allKeys]) 
    {
        NSString * mappedKey = [mapping objectForKey:wantedKey];
        if([mappedKey length])
            [self setValue:[keyedValues objectForKey:wantedKey] forKey:mappedKey];
#if DEBUG
        else
            NSLog(@"ignored key : %@ for class %@",wantedKey, [self class]);
#endif
    }
}

@end
