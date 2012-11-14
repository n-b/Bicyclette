//
//  NSSetAdditions.m
//
//  Created by Nicolas Bouilleaud a long time ago.
//

#import "NSSetAdditions.h"
#import "objc/message.h"


@implementation NSSet (Additions)

/****************************************************************************/
#pragma mark KVC-related Additions

- (id) anyObjectWithValue:(id)value forKey:(NSString*)key
{
	for (id object in self) {
		if( [[object valueForKey:key] isEqual:value] )
			return object;
	}
	return nil;
}

- (NSSet*) filteredSetWithValue:(id)value forKey:(NSString*)key
{
	NSMutableSet * objects = [NSMutableSet setWithCapacity:[self count]];
	
	for (id object in self) {
		if( [[object valueForKey:key] isEqual:value] )
			[objects addObject:object];
	}
	
	return [NSSet setWithSet:objects];
}

- (NSSet*) filteredSetWithSelector:(SEL)aFilterSelector
{
	NSMutableSet * objects = [NSMutableSet setWithCapacity:[self count]];
	
	for (id object in self)
	{
		// we need to only evaluate a BOOL, not the 4-byte or 8-byte result of performSelector
		// (see the literature on performSelector and ARC for details)
        //
        // * (long) casts the C-style pointer to an integer of the same byte count as a pointer.
        // * (BOOL) finally makes sure we only use the lower byte
		BOOL res = (BOOL) (long) objc_msgSend(object, aFilterSelector);
        
		if( res )
			[objects addObject:object];
	} 
	
	return [NSSet setWithSet:objects];
}

- (NSSet*) setByRemovingObjectsInSet:(NSSet*)otherSet
{
	NSMutableSet * result = [self mutableCopy];
	[result minusSet:otherSet];
	return [NSSet setWithSet:result];
}

@end

