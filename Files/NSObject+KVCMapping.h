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
/* 
 * Must be implemented by subclasses wishing to use KVC mapping.
 * The values of the returned dictionary must be actual properties keys of the object.
 * 
 * For non-NSManagedObject subclasses, any key not present in the mapping will be ignored.
 * For NSManagedObjects, keys not presents will be used without translation, only if the NSManagedObject has such properties.
 * 
 */
+ (NSDictionary*)kvcMapping;
@end
