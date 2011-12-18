// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Region.h instead.

#import <CoreData/CoreData.h>
#import "StationList.h"

extern const struct RegionAttributes {
	__unsafe_unretained NSString *maxLatitude;
	__unsafe_unretained NSString *maxLongitude;
	__unsafe_unretained NSString *minLatitude;
	__unsafe_unretained NSString *minLongitude;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *number;
} RegionAttributes;

extern const struct RegionRelationships {
} RegionRelationships;

extern const struct RegionFetchedProperties {
} RegionFetchedProperties;









@interface RegionID : NSManagedObjectID {}
@end

@interface _Region : StationList {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RegionID*)objectID;




@property (nonatomic, strong) NSNumber *maxLatitude;


@property double maxLatitudeValue;
- (double)maxLatitudeValue;
- (void)setMaxLatitudeValue:(double)value_;

//- (BOOL)validateMaxLatitude:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *maxLongitude;


@property double maxLongitudeValue;
- (double)maxLongitudeValue;
- (void)setMaxLongitudeValue:(double)value_;

//- (BOOL)validateMaxLongitude:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *minLatitude;


@property double minLatitudeValue;
- (double)minLatitudeValue;
- (void)setMinLatitudeValue:(double)value_;

//- (BOOL)validateMinLatitude:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *minLongitude;


@property double minLongitudeValue;
- (double)minLongitudeValue;
- (void)setMinLongitudeValue:(double)value_;

//- (BOOL)validateMinLongitude:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *number;


//- (BOOL)validateNumber:(id*)value_ error:(NSError**)error_;





+ (NSArray*)fetchRegionWithNumber:(NSManagedObjectContext*)moc_ number:(NSString*)number_ ;
+ (NSArray*)fetchRegionWithNumber:(NSManagedObjectContext*)moc_ number:(NSString*)number_ error:(NSError**)error_;



@end

@interface _Region (CoreDataGeneratedAccessors)

@end

@interface _Region (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveMaxLatitude;
- (void)setPrimitiveMaxLatitude:(NSNumber*)value;

- (double)primitiveMaxLatitudeValue;
- (void)setPrimitiveMaxLatitudeValue:(double)value_;




- (NSNumber*)primitiveMaxLongitude;
- (void)setPrimitiveMaxLongitude:(NSNumber*)value;

- (double)primitiveMaxLongitudeValue;
- (void)setPrimitiveMaxLongitudeValue:(double)value_;




- (NSNumber*)primitiveMinLatitude;
- (void)setPrimitiveMinLatitude:(NSNumber*)value;

- (double)primitiveMinLatitudeValue;
- (void)setPrimitiveMinLatitudeValue:(double)value_;




- (NSNumber*)primitiveMinLongitude;
- (void)setPrimitiveMinLongitude:(NSNumber*)value;

- (double)primitiveMinLongitudeValue;
- (void)setPrimitiveMinLongitudeValue:(double)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveNumber;
- (void)setPrimitiveNumber:(NSString*)value;




@end
