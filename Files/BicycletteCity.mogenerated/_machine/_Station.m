// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Station.m instead.

#import "_Station.h"

const struct StationAttributes StationAttributes = {
	.address = @"address",
	.bonus = @"bonus",
	.color = @"color",
	.fullAddress = @"fullAddress",
	.latitude = @"latitude",
	.longitude = @"longitude",
	.name = @"name",
	.number = @"number",
	.open = @"open",
	.starred = @"starred",
	.status_available = @"status_available",
	.status_date = @"status_date",
	.status_free = @"status_free",
	.status_ticket = @"status_ticket",
	.status_total = @"status_total",
};

const struct StationRelationships StationRelationships = {
	.region = @"region",
};

const struct StationFetchedProperties StationFetchedProperties = {
};

@implementation StationID
@end

@implementation _Station

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Station";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Station" inManagedObjectContext:moc_];
}

- (StationID*)objectID {
	return (StationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"bonusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"bonus"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"latitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"longitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"openValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"open"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"starredValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"starred"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"status_availableValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status_available"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"status_freeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status_free"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"status_ticketValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status_ticket"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"status_totalValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status_total"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic address;






@dynamic bonus;



- (BOOL)bonusValue {
	NSNumber *result = [self bonus];
	return [result boolValue];
}

- (void)setBonusValue:(BOOL)value_ {
	[self setBonus:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveBonusValue {
	NSNumber *result = [self primitiveBonus];
	return [result boolValue];
}

- (void)setPrimitiveBonusValue:(BOOL)value_ {
	[self setPrimitiveBonus:[NSNumber numberWithBool:value_]];
}





@dynamic color;






@dynamic fullAddress;






@dynamic latitude;



- (double)latitudeValue {
	NSNumber *result = [self latitude];
	return [result doubleValue];
}

- (void)setLatitudeValue:(double)value_ {
	[self setLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLatitudeValue {
	NSNumber *result = [self primitiveLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveLatitudeValue:(double)value_ {
	[self setPrimitiveLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic longitude;



- (double)longitudeValue {
	NSNumber *result = [self longitude];
	return [result doubleValue];
}

- (void)setLongitudeValue:(double)value_ {
	[self setLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLongitudeValue {
	NSNumber *result = [self primitiveLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLongitudeValue:(double)value_ {
	[self setPrimitiveLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic name;






@dynamic number;






@dynamic open;



- (BOOL)openValue {
	NSNumber *result = [self open];
	return [result boolValue];
}

- (void)setOpenValue:(BOOL)value_ {
	[self setOpen:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveOpenValue {
	NSNumber *result = [self primitiveOpen];
	return [result boolValue];
}

- (void)setPrimitiveOpenValue:(BOOL)value_ {
	[self setPrimitiveOpen:[NSNumber numberWithBool:value_]];
}





@dynamic starred;



- (BOOL)starredValue {
	NSNumber *result = [self starred];
	return [result boolValue];
}

- (void)setStarredValue:(BOOL)value_ {
	[self setStarred:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveStarredValue {
	NSNumber *result = [self primitiveStarred];
	return [result boolValue];
}

- (void)setPrimitiveStarredValue:(BOOL)value_ {
	[self setPrimitiveStarred:[NSNumber numberWithBool:value_]];
}





@dynamic status_available;



- (int16_t)status_availableValue {
	NSNumber *result = [self status_available];
	return [result shortValue];
}

- (void)setStatus_availableValue:(int16_t)value_ {
	[self setStatus_available:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveStatus_availableValue {
	NSNumber *result = [self primitiveStatus_available];
	return [result shortValue];
}

- (void)setPrimitiveStatus_availableValue:(int16_t)value_ {
	[self setPrimitiveStatus_available:[NSNumber numberWithShort:value_]];
}





@dynamic status_date;






@dynamic status_free;



- (int16_t)status_freeValue {
	NSNumber *result = [self status_free];
	return [result shortValue];
}

- (void)setStatus_freeValue:(int16_t)value_ {
	[self setStatus_free:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveStatus_freeValue {
	NSNumber *result = [self primitiveStatus_free];
	return [result shortValue];
}

- (void)setPrimitiveStatus_freeValue:(int16_t)value_ {
	[self setPrimitiveStatus_free:[NSNumber numberWithShort:value_]];
}





@dynamic status_ticket;



- (BOOL)status_ticketValue {
	NSNumber *result = [self status_ticket];
	return [result boolValue];
}

- (void)setStatus_ticketValue:(BOOL)value_ {
	[self setStatus_ticket:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveStatus_ticketValue {
	NSNumber *result = [self primitiveStatus_ticket];
	return [result boolValue];
}

- (void)setPrimitiveStatus_ticketValue:(BOOL)value_ {
	[self setPrimitiveStatus_ticket:[NSNumber numberWithBool:value_]];
}





@dynamic status_total;



- (int16_t)status_totalValue {
	NSNumber *result = [self status_total];
	return [result shortValue];
}

- (void)setStatus_totalValue:(int16_t)value_ {
	[self setStatus_total:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveStatus_totalValue {
	NSNumber *result = [self primitiveStatus_total];
	return [result shortValue];
}

- (void)setPrimitiveStatus_totalValue:(int16_t)value_ {
	[self setPrimitiveStatus_total:[NSNumber numberWithShort:value_]];
}





@dynamic region;

	






+ (NSArray*)fetchStarredStations:(NSManagedObjectContext*)moc_ {
	NSError *error = nil;
	NSArray *result = [self fetchStarredStations:moc_ error:&error];
	if (error) {
#ifdef NSAppKitVersionNumber10_0
		[NSApp presentError:error];
#else
		NSLog(@"error: %@", error);
#endif
	}
	return result;
}
+ (NSArray*)fetchStarredStations:(NSManagedObjectContext*)moc_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;

	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionary];
	
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"starredStations"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"starredStations\".");

	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



+ (NSArray*)fetchStationWithNumber:(NSManagedObjectContext*)moc_ number:(NSString*)number_ {
	NSError *error = nil;
	NSArray *result = [self fetchStationWithNumber:moc_ number:number_ error:&error];
	if (error) {
#ifdef NSAppKitVersionNumber10_0
		[NSApp presentError:error];
#else
		NSLog(@"error: %@", error);
#endif
	}
	return result;
}
+ (NSArray*)fetchStationWithNumber:(NSManagedObjectContext*)moc_ number:(NSString*)number_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;

	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionaryWithObjectsAndKeys:
														
														number_, @"number",
														
														nil];
	
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"stationWithNumber"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"stationWithNumber\".");

	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



+ (NSArray*)fetchStationsWithinRange:(NSManagedObjectContext*)moc_ minLatitude:(NSNumber*)minLatitude_ maxLatitude:(NSNumber*)maxLatitude_ minLongitude:(NSNumber*)minLongitude_ maxLongitude:(NSNumber*)maxLongitude_ {
	NSError *error = nil;
	NSArray *result = [self fetchStationsWithinRange:moc_ minLatitude:minLatitude_ maxLatitude:maxLatitude_ minLongitude:minLongitude_ maxLongitude:maxLongitude_ error:&error];
	if (error) {
#ifdef NSAppKitVersionNumber10_0
		[NSApp presentError:error];
#else
		NSLog(@"error: %@", error);
#endif
	}
	return result;
}
+ (NSArray*)fetchStationsWithinRange:(NSManagedObjectContext*)moc_ minLatitude:(NSNumber*)minLatitude_ maxLatitude:(NSNumber*)maxLatitude_ minLongitude:(NSNumber*)minLongitude_ maxLongitude:(NSNumber*)maxLongitude_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;

	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionaryWithObjectsAndKeys:
														
														minLatitude_, @"minLatitude",
														
														maxLatitude_, @"maxLatitude",
														
														minLongitude_, @"minLongitude",
														
														maxLongitude_, @"maxLongitude",
														
														nil];
	
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"stationsWithinRange"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"stationsWithinRange\".");

	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



@end
