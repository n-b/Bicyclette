// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Region.m instead.

#import "_Region.h"

@implementation RegionID
@end

@implementation _Region

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Region";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Region" inManagedObjectContext:moc_];
}

- (RegionID*)objectID {
	return (RegionID*)[super objectID];
}




@dynamic name;






@dynamic longName;






@dynamic stations;

	
- (NSMutableSet*)stationsSet {
	[self willAccessValueForKey:@"stations"];
	NSMutableSet *result = [self mutableSetValueForKey:@"stations"];
	[self didAccessValueForKey:@"stations"];
	return result;
}
	






+ (NSArray*)fetchRegionWithName:(NSManagedObjectContext*)moc_ name:(NSString*)name_ {
	NSError *error = nil;
	NSArray *result = [self fetchRegionWithName:moc_ name:name_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchRegionWithName:(NSManagedObjectContext*)moc_ name:(NSString*)name_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionaryWithObjectsAndKeys:
														
														name_, @"name",
														
														nil];
										
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"regionWithName"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"regionWithName\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}


@end
