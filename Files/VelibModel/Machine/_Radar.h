// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Radar.h instead.

#import <CoreData/CoreData.h>


extern const struct RadarAttributes {
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
} RadarAttributes;

extern const struct RadarRelationships {
} RadarRelationships;

extern const struct RadarFetchedProperties {
} RadarFetchedProperties;






@interface RadarID : NSManagedObjectID {}
@end

@interface _Radar : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RadarID*)objectID;




@property (nonatomic, strong) NSString* identifier;


//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* latitude;


@property double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* longitude;


@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;





+ (NSArray*)fetchUserLocationRadar:(NSManagedObjectContext*)moc_ ;
+ (NSArray*)fetchUserLocationRadar:(NSManagedObjectContext*)moc_ error:(NSError**)error_;



+ (NSArray*)fetchScreenCenterRadar:(NSManagedObjectContext*)moc_ ;
+ (NSArray*)fetchScreenCenterRadar:(NSManagedObjectContext*)moc_ error:(NSError**)error_;




@end

@interface _Radar (CoreDataGeneratedAccessors)

@end

@interface _Radar (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;




- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;




@end
