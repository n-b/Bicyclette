// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Bookmark.m instead.

#import "_Bookmark.h"

const struct BookmarkAttributes BookmarkAttributes = {
	.color = @"color",
};

const struct BookmarkRelationships BookmarkRelationships = {
	.list = @"list",
	.station = @"station",
};

const struct BookmarkFetchedProperties BookmarkFetchedProperties = {
};

@implementation BookmarkID
@end

@implementation _Bookmark

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Bookmark";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:moc_];
}

- (BookmarkID*)objectID {
	return (BookmarkID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic color;






@dynamic list;

	

@dynamic station;

	





@end
