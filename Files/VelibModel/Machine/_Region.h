// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Region.h instead.

#import <CoreData/CoreData.h>


@class Station;








@interface RegionID : NSManagedObjectID {}
@end

@interface _Region : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RegionID*)objectID;




@property (nonatomic, retain) NSNumber *maxLatitude;


@property double maxLatitudeValue;
- (double)maxLatitudeValue;
- (void)setMaxLatitudeValue:(double)value_;

//- (BOOL)validateMaxLatitude:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *maxLongitude;


@property double maxLongitudeValue;
- (double)maxLongitudeValue;
- (void)setMaxLongitudeValue:(double)value_;

//- (BOOL)validateMaxLongitude:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *minLatitude;


@property double minLatitudeValue;
- (double)minLatitudeValue;
- (void)setMinLatitudeValue:(double)value_;

//- (BOOL)validateMinLatitude:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *minLongitude;


@property double minLongitudeValue;
- (double)minLongitudeValue;
- (void)setMinLongitudeValue:(double)value_;

//- (BOOL)validateMinLongitude:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *number;


//- (BOOL)validateNumber:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet* stations;

- (NSMutableSet*)stationsSet;




+ (NSArray*)fetchRegionWithNumber:(NSManagedObjectContext*)moc_ number:(NSString*)number_ ;
+ (NSArray*)fetchRegionWithNumber:(NSManagedObjectContext*)moc_ number:(NSString*)number_ error:(NSError**)error_;



@end

@interface _Region (CoreDataGeneratedAccessors)

- (void)addStations:(NSSet*)value_;
- (void)removeStations:(NSSet*)value_;
- (void)addStationsObject:(Station*)value_;
- (void)removeStationsObject:(Station*)value_;

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





- (NSMutableSet*)primitiveStations;
- (void)setPrimitiveStations:(NSMutableSet*)value;


@end
