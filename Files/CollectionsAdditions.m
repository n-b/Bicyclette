//
//  CollectionsAdditions.m
//
//  Created by Nicolas Bouilleaud a long time ago.
//

#import "CollectionsAdditions.h"

@implementation NSArray (Additions)

- (id) firstObjectWithValue:(id)value forKeyPath:(NSString*)key
{
	for (id object in self) {
		if( [[object valueForKeyPath:key] isEqual:value] )
			return object;
	}
	return nil;
}

- (NSArray*) filteredArrayWithValue:(id)value forKeyPath:(NSString*)key
{
	NSMutableArray * objects = [NSMutableArray arrayWithCapacity:[self count]];
	
	for (id object in self) {
		if( [[object valueForKeyPath:key] isEqual:value] )
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


@implementation NSSet (Additions)

- (id) anyObjectWithValue:(id)value forKeyPath:(NSString*)key
{
	for (id object in self) {
		if( [[object valueForKeyPath:key] isEqual:value] )
			return object;
	}
	return nil;
}

- (NSSet*) filteredSetWithValue:(id)value forKeyPath:(NSString*)key
{
	NSMutableSet * objects = [NSMutableSet setWithCapacity:[self count]];
	
	for (id object in self) {
		if( [[object valueForKeyPath:key] isEqual:value] )
			[objects addObject:object];
	}
	
	return [NSSet setWithSet:objects];
}

@end

