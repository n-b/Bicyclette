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



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *minLng;

@property double minLngValue;
- (double)minLngValue;
- (void)setMinLngValue:(double)value_;

//- (BOOL)validateMinLng:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *minLat;

@property double minLatValue;
- (double)minLatValue;
- (void)setMinLatValue:(double)value_;

//- (BOOL)validateMinLat:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *maxLng;

@property double maxLngValue;
- (double)maxLngValue;
- (void)setMaxLngValue:(double)value_;

//- (BOOL)validateMaxLng:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *maxLat;

@property double maxLatValue;
- (double)maxLatValue;
- (void)setMaxLatValue:(double)value_;

//- (BOOL)validateMaxLat:(id*)value_ error:(NSError**)error_;



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


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveMinLng;
- (void)setPrimitiveMinLng:(NSNumber*)value;

- (double)primitiveMinLngValue;
- (void)setPrimitiveMinLngValue:(double)value_;




- (NSNumber*)primitiveMinLat;
- (void)setPrimitiveMinLat:(NSNumber*)value;

- (double)primitiveMinLatValue;
- (void)setPrimitiveMinLatValue:(double)value_;




- (NSNumber*)primitiveMaxLng;
- (void)setPrimitiveMaxLng:(NSNumber*)value;

- (double)primitiveMaxLngValue;
- (void)setPrimitiveMaxLngValue:(double)value_;




- (NSNumber*)primitiveMaxLat;
- (void)setPrimitiveMaxLat:(NSNumber*)value;

- (double)primitiveMaxLatValue;
- (void)setPrimitiveMaxLatValue:(double)value_;




- (NSString*)primitiveNumber;
- (void)setPrimitiveNumber:(NSString*)value;





- (NSMutableSet*)primitiveStations;
- (void)setPrimitiveStations:(NSMutableSet*)value;


@end
