//
//  NSObject+KVCMapping.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 18/06/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define NAMEDPROP(propName)    NSStringFromSelector(@selector(propName))
#else
#define NAMEDPROP(propName)    @#propName
#endif

@interface NSObject (NSObject_KVCMapping)
- (void) setValue:(id)value forMappedKey:(NSString*)wantedKey;
- (void) setValuesForMappedKeysWithDictionary:(NSDictionary *)keyedValues;
@end


@interface NSObject (NSObject_KVCMapping_Support)
+ (NSDictionary*)kvcMapping;
@end
