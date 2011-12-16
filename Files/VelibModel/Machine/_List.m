// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to List.m instead.

#import "_List.h"

const struct ListAttributes ListAttributes = {
	.name = @"name",
};

const struct ListRelationships ListRelationships = {
	.bookmarks = @"bookmarks",
};

const struct ListFetchedProperties ListFetchedProperties = {
};

@implementation ListID
@end

@implementation _List

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"List";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"List" inManagedObjectContext:moc_];
}

- (ListID*)objectID {
	return (ListID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic bookmarks;

	
- (NSMutableOrderedSet*)bookmarksSet {
	[self willAccessValueForKey:@"bookmarks"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"bookmarks"];
  
	[self didAccessValueForKey:@"bookmarks"];
	return result;
}
	





@end
