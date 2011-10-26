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
/* 
 * KVC Mapping
 * 
 * The passed mapping dictionary is used to translate the wantedKey (the key name in the external representation,
 * like a webservice) to the real object property.
 * The NSDictionary keys and values should only be NSStrings.
 * 
 * For NSManagedObjects, setValue:forKey:withMappingDictionary also does automatic type coercion from string to numbers.
 */
- (void) setValue:(id)value forKey:(NSString*)wantedKey withMappingDictionary:(NSDictionary*)kvcMappingDictionnary;
- (void) setValuesForKeysWithDictionary:(NSDictionary *)keyedValues withMappingDictionary:(NSDictionary*)kvcMappingDictionnary;
@end

