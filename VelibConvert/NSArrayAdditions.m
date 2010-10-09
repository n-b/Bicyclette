//
//  NSArrayAdditions.m
//
//  Created by Nicolas Bouilleaud a long time ago.
//

#import "NSArrayAdditions.h"


@implementation NSArray (Additions)

/****************************************************************************/
#pragma mark KVC-related Additions
// Using enumerators is probably faster than using NSPredicates.
// Moreover, predicates are 10.4+ only.
//
// In a 10.5 / Objective-C 2.0 World, we'd use fast enums.

- (id) firstObjectWithValue:(id)value forKey:(NSString*)key
{
	NSEnumerator* objectEnum = [self objectEnumerator];
	id object;
	
	while( (object = [objectEnum nextObject]) !=nil )
		if( [[object valueForKey:key] isEqual:value] )
			return object;
	return nil;
}

- (NSArray*) filteredArrayWithValue:(id)value forKey:(NSString*)key
{
	NSMutableArray * objects = [NSMutableArray arrayWithCapacity:[self count]];
	NSEnumerator* objectEnum = [self objectEnumerator];
	id object;
	
	while( (object = [objectEnum nextObject]) !=nil )
		if( [[object valueForKey:key] isEqual:value] )
			[objects addObject:object];
	
	return [NSArray arrayWithArray:objects];
}

- (NSArray*) filteredArrayWithSelector:(SEL)aFilterSelector
{
	NSMutableArray * objects = [NSMutableArray arrayWithCapacity:[self count]];
	NSEnumerator* objectEnum = [self objectEnumerator];
	id object;
	
	while( (object = [objectEnum nextObject]) !=nil )
	{
		// we need to only evaluate a BOOL, not the 4-byte result of performSelector
		// (see the literature on performSelector for details)
		BOOL res = (BOOL) (long) [object performSelector:aFilterSelector];
		if( res )
			[objects addObject:object];
	} 
	
	return [NSArray arrayWithArray:objects];
}


@end
