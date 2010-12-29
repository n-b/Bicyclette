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






@dynamic minLng;



- (double)minLngValue {
	NSNumber *result = [self minLng];
	return [result doubleValue];
}

- (void)setMinLngValue:(double)value_ {
	[self setMinLng:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveMinLngValue {
	NSNumber *result = [self primitiveMinLng];
	return [result doubleValue];
}

- (void)setPrimitiveMinLngValue:(double)value_ {
	[self setPrimitiveMinLng:[NSNumber numberWithDouble:value_]];
}





@dynamic minLat;



- (double)minLatValue {
	NSNumber *result = [self minLat];
	return [result doubleValue];
}

- (void)setMinLatValue:(double)value_ {
	[self setMinLat:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveMinLatValue {
	NSNumber *result = [self primitiveMinLat];
	return [result doubleValue];
}

- (void)setPrimitiveMinLatValue:(double)value_ {
	[self setPrimitiveMinLat:[NSNumber numberWithDouble:value_]];
}





@dynamic maxLng;



- (double)maxLngValue {
	NSNumber *result = [self maxLng];
	return [result doubleValue];
}

- (void)setMaxLngValue:(double)value_ {
	[self setMaxLng:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveMaxLngValue {
	NSNumber *result = [self primitiveMaxLng];
	return [result doubleValue];
}

- (void)setPrimitiveMaxLngValue:(double)value_ {
	[self setPrimitiveMaxLng:[NSNumber numberWithDouble:value_]];
}





@dynamic maxLat;



- (double)maxLatValue {
	NSNumber *result = [self maxLat];
	return [result doubleValue];
}

- (void)setMaxLatValue:(double)value_ {
	[self setMaxLat:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveMaxLatValue {
	NSNumber *result = [self primitiveMaxLat];
	return [result doubleValue];
}

- (void)setPrimitiveMaxLatValue:(double)value_ {
	[self setPrimitiveMaxLat:[NSNumber numberWithDouble:value_]];
}





@dynamic number;






@dynamic stations;

	
- (NSMutableSet*)stationsSet {
	[self willAccessValueForKey:@"stations"];
	NSMutableSet *result = [self mutableSetValueForKey:@"stations"];
	[self didAccessValueForKey:@"stations"];
	return result;
}
	






+ (NSArray*)fetchRegionWithNumber:(NSManagedObjectContext*)moc_ number:(NSString*)number_ {
	NSError *error = nil;
	NSArray *result = [self fetchRegionWithNumber:moc_ number:number_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchRegionWithNumber:(NSManagedObjectContext*)moc_ number:(NSString*)number_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionaryWithObjectsAndKeys:
														
														number_, @"number",
														
														nil];
										
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"regionWithNumber"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"regionWithNumber\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}


@end
