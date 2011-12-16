// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Bookmark.h instead.

#import <CoreData/CoreData.h>


extern const struct BookmarkAttributes {
	__unsafe_unretained NSString *color;
} BookmarkAttributes;

extern const struct BookmarkRelationships {
	__unsafe_unretained NSString *list;
	__unsafe_unretained NSString *station;
} BookmarkRelationships;

extern const struct BookmarkFetchedProperties {
} BookmarkFetchedProperties;

@class List;
@class Station;

@class UIColor;

@interface BookmarkID : NSManagedObjectID {}
@end

@interface _Bookmark : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BookmarkID*)objectID;




@property (nonatomic, strong) UIColor *color;


//- (BOOL)validateColor:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) List* list;

//- (BOOL)validateList:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Station* station;

//- (BOOL)validateStation:(id*)value_ error:(NSError**)error_;




@end

@interface _Bookmark (CoreDataGeneratedAccessors)

@end

@interface _Bookmark (CoreDataGeneratedPrimitiveAccessors)


- (UIColor*)primitiveColor;
- (void)setPrimitiveColor:(UIColor*)value;





- (List*)primitiveList;
- (void)setPrimitiveList:(List*)value;



- (Station*)primitiveStation;
- (void)setPrimitiveStation:(Station*)value;


@end
