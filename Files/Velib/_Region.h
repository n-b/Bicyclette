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



@property (nonatomic, retain) NSString *longName;

//- (BOOL)validateLongName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* stations;
- (NSMutableSet*)stationsSet;




+ (NSArray*)fetchRegionWithName:(NSManagedObjectContext*)moc_ name:(NSString*)name_ ;
+ (NSArray*)fetchRegionWithName:(NSManagedObjectContext*)moc_ name:(NSString*)name_ error:(NSError**)error_;



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


- (NSString*)primitiveLongName;
- (void)setPrimitiveLongName:(NSString*)value;




- (NSMutableSet*)primitiveStations;
- (void)setPrimitiveStations:(NSMutableSet*)value;


@end
