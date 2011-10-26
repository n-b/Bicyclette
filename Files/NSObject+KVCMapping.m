//
//  NSObject+KVCMapping.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 18/06/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "NSObject+KVCMapping.h"
#define DEBUG_KV_MAPPING 0

@implementation NSObject (NSObject_KVCMapping)

- (void) setValue:(id)value forKey:(NSString*)wantedKey withMappingDictionary:(NSDictionary*)kvcMappingDictionnary
{
    NSString * realKey = [kvcMappingDictionnary objectForKey:wantedKey];
    if([realKey length])
        [self setValue:value forKey:realKey];
#if DEBUG
    else
        NSLog(@"ignored key : %@ for class %@",wantedKey, [self class]);
#endif
}

- (void) setValuesForKeysWithDictionary:(NSDictionary *)keyedValues withMappingDictionary:(NSDictionary*)kvcMappingDictionnary
{
    for (NSString * wantedKey in [keyedValues allKeys]) 
        [self setValue:[keyedValues objectForKey:wantedKey] forKey:wantedKey withMappingDictionary:kvcMappingDictionnary];
}

@end

/****************************************************************************/
#pragma mark -

@implementation NSManagedObject (NSObject_KVCMapping)

- (void) setValue:(id)value forMappedKey:(NSString*)wantedKey withMappingDictionary:(NSDictionary*)mapping
{
    NSString * realKey = [mapping objectForKey:wantedKey];
    
    NSAttributeDescription * attributeDesc = [[[(NSManagedObject*)self entity] attributesByName] objectForKey:realKey];
    if(attributeDesc)
    {
        id correctValue = nil;
        
        NSAttributeType attributeType = attributeDesc.attributeType;
        Class expectedClass = NSClassFromString(attributeDesc.attributeValueClassName);

        if([value isKindOfClass:expectedClass])
            correctValue = value;
        else
        {
            switch (attributeType) 
            {
                    // Numbers
                    /*
                     Notes :
                     * Core data has only signed integers,
                     * There's no "shortValue" in NSString,
                     * Using intValue always return a 32-bit integer (an int), while integerValue returns an NSInteger, which may be 64-bit.
                     */
                case NSBooleanAttributeType :
                    if([value respondsToSelector:@selector(boolValue)])
                        correctValue = [NSNumber numberWithBool:[value boolValue]];  
                    break;
                case NSInteger16AttributeType :
                case NSInteger32AttributeType :
                    if([value respondsToSelector:@selector(intValue)])
                        correctValue = [NSNumber numberWithLong:[value intValue]];  
                    break;
                case NSInteger64AttributeType :
                    if([value respondsToSelector:@selector(longLongValue)])
                        correctValue = [NSNumber numberWithLongLong:[value longLongValue]];  
                    break;
                case NSDecimalAttributeType :
                    if([value isKindOfClass:[NSString self]])
                        correctValue = [NSDecimalNumber decimalNumberWithString:value];  
                    break;
                case NSDoubleAttributeType :
                    if([value respondsToSelector:@selector(doubleValue)])
                        correctValue = [NSNumber numberWithDouble:[value doubleValue]];  
                    break;
                case NSFloatAttributeType :
                    if([value respondsToSelector:@selector(floatValue)])
                        correctValue = [NSNumber numberWithFloat:[value floatValue]];  
                    break;
                    
                    // NSStrings
                case NSStringAttributeType : 
                    if([value respondsToSelector:@selector(stringValue)])
                        correctValue = [value stringValue];
                    break;
                    
                    // Date and Data
                    // There is a need for specific date format parsing here.
                case NSDateAttributeType :
                case NSBinaryDataAttributeType:
                    break;
                    
                    // Default behaviour for these (probably gonna crash later anyway)
                case NSTransformableAttributeType:
                case NSObjectIDAttributeType:
                default :
                    correctValue = value;
                    break;
            }
#if DEBUG && DEBUG_KV_MAPPING
            if(correctValue)
                NSLog(@"fixed %@(%@) to %@(%@) for key %@(%@) of class %@",
                      value, [value class], correctValue, [correctValue class], realKey, wantedKey, [self class]);
            else
                NSLog(@"invalid value : %@(%@), expected %@ for key %@(%@) of class %@",
                      value, [value class], expectedClass, realKey, wantedKey, [self class]);
#endif
        }

        NSAssert([[correctValue class] isSubclassOfClass:expectedClass],
                 @"The result value %@(%@) is incorrect (expected %@) for key %@(%@) of class %@",
                 correctValue, [correctValue class], expectedClass, realKey, wantedKey, [self class]);
        if(correctValue)
            [self setValue:correctValue forKey:realKey];
    }
#if DEBUG
    else
        NSLog(@"ignored key : %@ for class %@",wantedKey, [self class]);
#endif
}

@end
