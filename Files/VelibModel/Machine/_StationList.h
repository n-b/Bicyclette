// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StationList.h instead.

#import <CoreData/CoreData.h>


extern const struct StationListAttributes {
} StationListAttributes;

extern const struct StationListRelationships {
	__unsafe_unretained NSString *stations;
} StationListRelationships;

extern const struct StationListFetchedProperties {
} StationListFetchedProperties;

@class Station;


@interface StationListID : NSManagedObjectID {}
@end

@interface _StationList : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StationListID*)objectID;





@property (nonatomic, strong) NSOrderedSet* stations;

- (NSMutableOrderedSet*)stationsSet;





@end

@interface _StationList (CoreDataGeneratedAccessors)

- (void)addStations:(NSOrderedSet*)value_;
- (void)removeStations:(NSOrderedSet*)value_;
- (void)addStationsObject:(Station*)value_;
- (void)removeStationsObject:(Station*)value_;

@end

@interface _StationList (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableOrderedSet*)primitiveStations;
- (void)setPrimitiveStations:(NSMutableOrderedSet*)value;


@end
