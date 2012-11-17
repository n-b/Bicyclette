//
//  NSArrayAdditions.m
//
//  Created by Nicolas Bouilleaud a long time ago.
//

#import "NSArrayAdditions.h"
#import "objc/message.h"


@implementation NSArray (Additions)

- (id) firstObjectWithValue:(id)value forKey:(NSString*)key
{
	for (id object in self) {
		if( [[object valueForKey:key] isEqual:value] )
			return object;
	}
	return nil;
}

- (NSArray*) filteredArrayWithValue:(id)value forKey:(NSString*)key
{
	NSMutableArray * objects = [NSMutableArray arrayWithCapacity:[self count]];
	
	for (id object in self) {
		if( [[object valueForKey:key] isEqual:value] )
			[objects addObject:object];
	}
	
	return [NSArray arrayWithArray:objects];
}

- (NSArray*) arrayByRemovingObjectsInArray:(NSArray*)otherArray
{
	NSMutableArray * result = [self mutableCopy];
	[result removeObjectsInArray:otherArray];
	return result;
}

@end

