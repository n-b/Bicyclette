// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Section.m instead.

#import "_Section.h"

@implementation SectionID
@end

@implementation _Section

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Section" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Section";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Section" inManagedObjectContext:moc_];
}

- (SectionID*)objectID {
	return (SectionID*)[super objectID];
}




@dynamic name;






@dynamic sort_index;



- (short)sort_indexValue {
	NSNumber *result = [self sort_index];
	return [result shortValue];
}

- (void)setSort_indexValue:(short)value_ {
	[self setSort_index:[NSNumber numberWithShort:value_]];
}

- (short)primitiveSort_indexValue {
	NSNumber *result = [self primitiveSort_index];
	return [result shortValue];
}

- (void)setPrimitiveSort_indexValue:(short)value_ {
	[self setPrimitiveSort_index:[NSNumber numberWithShort:value_]];
}





@dynamic stations;

	
- (NSMutableSet*)stationsSet {
	[self willAccessValueForKey:@"stations"];
	NSMutableSet *result = [self mutableSetValueForKey:@"stations"];
	[self didAccessValueForKey:@"stations"];
	return result;
}
	




+ (NSArray*)fetchSections:(NSManagedObjectContext*)moc_ {
	NSError *error = nil;
	NSArray *result = [self fetchSections:moc_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchSections:(NSManagedObjectContext*)moc_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = nil;
										
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"sections"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"sections\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



+ (NSArray*)fetchSectionWithName:(NSManagedObjectContext*)moc_ name:(NSString*)name_ {
	NSError *error = nil;
	NSArray *result = [self fetchSectionWithName:moc_ name:name_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchSectionWithName:(NSManagedObjectContext*)moc_ name:(NSString*)name_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionaryWithObjectsAndKeys:
														
														name_, @"name",
														
														nil];
										
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"sectionWithName"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"sectionWithName\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}


@end
