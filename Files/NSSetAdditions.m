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

@end

