// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Station.m instead.

#import "_Station.h"

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




@dynamic fullAddress;






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





@dynamic status_date;






@dynamic address;






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





@dynamic lat;



- (double)latValue {
	NSNumber *result = [self lat];
	return [result doubleValue];
}

- (void)setLatValue:(double)value_ {
	[self setLat:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLatValue {
	NSNumber *result = [self primitiveLat];
	return [result doubleValue];
}

- (void)setPrimitiveLatValue:(double)value_ {
	[self setPrimitiveLat:[NSNumber numberWithDouble:value_]];
}





@dynamic create_date;






@dynamic favorite_index;



- (int)favorite_indexValue {
	NSNumber *result = [self favorite_index];
	return [result intValue];
}

- (void)setFavorite_indexValue:(int)value_ {
	[self setFavorite_index:[NSNumber numberWithInt:value_]];
}

- (int)primitiveFavorite_indexValue {
	NSNumber *result = [self primitiveFavorite_index];
	return [result intValue];
}

- (void)setPrimitiveFavorite_indexValue:(int)value_ {
	[self setPrimitiveFavorite_index:[NSNumber numberWithInt:value_]];
}





@dynamic lng;



- (double)lngValue {
	NSNumber *result = [self lng];
	return [result doubleValue];
}

- (void)setLngValue:(double)value_ {
	[self setLng:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLngValue {
	NSNumber *result = [self primitiveLng];
	return [result doubleValue];
}

- (void)setPrimitiveLngValue:(double)value_ {
	[self setPrimitiveLng:[NSNumber numberWithDouble:value_]];
}





@dynamic name;






@dynamic code_postal;






@dynamic number;









+ (NSArray*)fetchStationWithNumber:(NSManagedObjectContext*)moc_ number:(NSString*)number_ {
	NSError *error = nil;
	NSArray *result = [self fetchStationWithNumber:moc_ number:number_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
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


@end
