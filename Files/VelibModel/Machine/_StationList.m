// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StationList.m instead.

#import "_StationList.h"

const struct StationListAttributes StationListAttributes = {
};

const struct StationListRelationships StationListRelationships = {
	.stations = @"stations",
};

const struct StationListFetchedProperties StationListFetchedProperties = {
};

@implementation StationListID
@end

@implementation _StationList

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"StationList" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"StationList";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"StationList" inManagedObjectContext:moc_];
}

- (StationListID*)objectID {
	return (StationListID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic stations;

	
- (NSMutableOrderedSet*)stationsSet {
	[self willAccessValueForKey:@"stations"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"stations"];
  
	[self didAccessValueForKey:@"stations"];
	return result;
}
	






@end
