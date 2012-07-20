//
//  NSArrayAdditions.m
//
//  Created by Nicolas Bouilleaud a long time ago.
//

#import "NSArrayAdditions.h"
#import "objc/message.h"


@implementation NSArray (Additions)

/****************************************************************************/
#pragma mark KVC-related Additions

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

- (NSArray*) filteredArrayWithSelector:(SEL)aFilterSelector
{
	NSMutableArray * objects = [NSMutableArray arrayWithCapacity:[self count]];
	
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
	
	return [NSArray arrayWithArray:objects];
}

- (NSArray*) arrayByRemovingObjectsInArray:(NSArray*)otherArray
{
	NSMutableArray * result = [self mutableCopy];
	[result removeObjectsInArray:otherArray];
	return result;
}

@end


@implementation NSMutableArray (Additions)

- (void) sortWithProperty:(NSString *) property
{
	[self sortUsingDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:property ascending:YES] ]];
}

@end
