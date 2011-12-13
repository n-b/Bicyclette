// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Region.m instead.

#import "_Region.h"

const struct RegionAttributes RegionAttributes = {
	.maxLatitude = @"maxLatitude",
	.maxLongitude = @"maxLongitude",
	.minLatitude = @"minLatitude",
	.minLongitude = @"minLongitude",
	.name = @"name",
	.number = @"number",
};

const struct RegionRelationships RegionRelationships = {
	.stations = @"stations",
};

const struct RegionFetchedProperties RegionFetchedProperties = {
};

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

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"maxLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"maxLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"maxLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"maxLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"minLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"minLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"minLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"minLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic maxLatitude;



- (double)maxLatitudeValue {
	NSNumber *result = [self maxLatitude];
	return [result doubleValue];
}

- (void)setMaxLatitudeValue:(double)value_ {
	[self setMaxLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveMaxLatitudeValue {
	NSNumber *result = [self primitiveMaxLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveMaxLatitudeValue:(double)value_ {
	[self setPrimitiveMaxLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic maxLongitude;



- (double)maxLongitudeValue {
	NSNumber *result = [self maxLongitude];
	return [result doubleValue];
}

- (void)setMaxLongitudeValue:(double)value_ {
	[self setMaxLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveMaxLongitudeValue {
	NSNumber *result = [self primitiveMaxLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveMaxLongitudeValue:(double)value_ {
	[self setPrimitiveMaxLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic minLatitude;



- (double)minLatitudeValue {
	NSNumber *result = [self minLatitude];
	return [result doubleValue];
}

- (void)setMinLatitudeValue:(double)value_ {
	[self setMinLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveMinLatitudeValue {
	NSNumber *result = [self primitiveMinLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveMinLatitudeValue:(double)value_ {
	[self setPrimitiveMinLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic minLongitude;



- (double)minLongitudeValue {
	NSNumber *result = [self minLongitude];
	return [result doubleValue];
}

- (void)setMinLongitudeValue:(double)value_ {
	[self setMinLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveMinLongitudeValue {
	NSNumber *result = [self primitiveMinLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveMinLongitudeValue:(double)value_ {
	[self setPrimitiveMinLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic name;






@dynamic number;






@dynamic stations;

	
- (NSMutableOrderedSet*)stationsSet {
	[self willAccessValueForKey:@"stations"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"stations"];
  
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
