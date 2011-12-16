// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Station.m instead.

#import "_Station.h"

const struct StationAttributes StationAttributes = {
	.address = @"address",
	.bonus = @"bonus",
	.fullAddress = @"fullAddress",
	.latitude = @"latitude",
	.longitude = @"longitude",
	.name = @"name",
	.number = @"number",
	.open = @"open",
	.status_available = @"status_available",
	.status_date = @"status_date",
	.status_free = @"status_free",
	.status_ticket = @"status_ticket",
	.status_total = @"status_total",
};

const struct StationRelationships StationRelationships = {
	.bookmarks = @"bookmarks",
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

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"bonusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"bonus"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"latitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"longitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"openValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"open"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"status_availableValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status_available"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"status_freeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status_free"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"status_ticketValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status_ticket"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"status_totalValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status_total"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
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





@dynamic status_available;



- (short)status_availableValue {
	NSNumber *result = [self status_available];
	return [result shortValue];
}

- (void)setStatus_availableValue:(short)value_ {
	[self setStatus_available:[NSNumber numberWithShort:value_]];
}

- (short)primitiveStatus_availableValue {
	NSNumber *result = [self primitiveStatus_available];
	return [result shortValue];
}

- (void)setPrimitiveStatus_availableValue:(short)value_ {
	[self setPrimitiveStatus_available:[NSNumber numberWithShort:value_]];
}





@dynamic status_date;






@dynamic status_free;



- (short)status_freeValue {
	NSNumber *result = [self status_free];
	return [result shortValue];
}

- (void)setStatus_freeValue:(short)value_ {
	[self setStatus_free:[NSNumber numberWithShort:value_]];
}

- (short)primitiveStatus_freeValue {
	NSNumber *result = [self primitiveStatus_free];
	return [result shortValue];
}

- (void)setPrimitiveStatus_freeValue:(short)value_ {
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



- (short)status_totalValue {
	NSNumber *result = [self status_total];
	return [result shortValue];
}

- (void)setStatus_totalValue:(short)value_ {
	[self setStatus_total:[NSNumber numberWithShort:value_]];
}

- (short)primitiveStatus_totalValue {
	NSNumber *result = [self primitiveStatus_total];
	return [result shortValue];
}

- (void)setPrimitiveStatus_totalValue:(short)value_ {
	[self setPrimitiveStatus_total:[NSNumber numberWithShort:value_]];
}





@dynamic bookmarks;

	
- (NSMutableSet*)bookmarksSet {
	[self willAccessValueForKey:@"bookmarks"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"bookmarks"];
  
	[self didAccessValueForKey:@"bookmarks"];
	return result;
}
	

@dynamic region;

	





@end
