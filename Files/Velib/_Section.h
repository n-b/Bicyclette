// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Section.h instead.

#import <CoreData/CoreData.h>


@class Station;




@interface SectionID : NSManagedObjectID {}
@end

@interface _Section : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SectionID*)objectID;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *sort_index;

@property short sort_indexValue;
- (short)sort_indexValue;
- (void)setSort_indexValue:(short)value_;

//- (BOOL)validateSort_index:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* stations;
- (NSMutableSet*)stationsSet;




+ (NSArray*)fetchSections:(NSManagedObjectContext*)moc_ ;
+ (NSArray*)fetchSections:(NSManagedObjectContext*)moc_ error:(NSError**)error_;



+ (NSArray*)fetchSectionWithName:(NSManagedObjectContext*)moc_ name:(NSString*)name_ ;
+ (NSArray*)fetchSectionWithName:(NSManagedObjectContext*)moc_ name:(NSString*)name_ error:(NSError**)error_;


@end

@interface _Section (CoreDataGeneratedAccessors)

- (void)addStations:(NSSet*)value_;
- (void)removeStations:(NSSet*)value_;
- (void)addStationsObject:(Station*)value_;
- (void)removeStationsObject:(Station*)value_;

@end

@interface _Section (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;


- (NSNumber*)primitiveSort_index;
- (void)setPrimitiveSort_index:(NSNumber*)value;

- (short)primitiveSort_indexValue;
- (void)setPrimitiveSort_indexValue:(short)value_;




- (NSMutableSet*)primitiveStations;
- (void)setPrimitiveStations:(NSMutableSet*)value;


@end
