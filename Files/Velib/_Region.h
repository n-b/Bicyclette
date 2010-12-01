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



@property (nonatomic, retain) NSString *code_postal;

//- (BOOL)validateCode_postal:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* stations;
- (NSMutableSet*)stationsSet;




+ (NSArray*)fetchRegionWithCodePostal:(NSManagedObjectContext*)moc_ code_postal:(NSString*)code_postal_ ;
+ (NSArray*)fetchRegionWithCodePostal:(NSManagedObjectContext*)moc_ code_postal:(NSString*)code_postal_ error:(NSError**)error_;



@end

@interface _Region (CoreDataGeneratedAccessors)

- (void)addStations:(NSSet*)value_;
- (void)removeStations:(NSSet*)value_;
- (void)addStationsObject:(Station*)value_;
- (void)removeStationsObject:(Station*)value_;

@end

@interface _Region (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCode_postal;
- (void)setPrimitiveCode_postal:(NSString*)value;




- (NSMutableSet*)primitiveStations;
- (void)setPrimitiveStations:(NSMutableSet*)value;


@end
