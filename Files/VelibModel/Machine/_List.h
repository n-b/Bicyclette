// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to List.h instead.

#import <CoreData/CoreData.h>


extern const struct ListAttributes {
	__unsafe_unretained NSString *name;
} ListAttributes;

extern const struct ListRelationships {
	__unsafe_unretained NSString *bookmarks;
} ListRelationships;

extern const struct ListFetchedProperties {
} ListFetchedProperties;

@class Bookmark;



@interface ListID : NSManagedObjectID {}
@end

@interface _List : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ListID*)objectID;




@property (nonatomic, strong) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSOrderedSet* bookmarks;

- (NSMutableOrderedSet*)bookmarksSet;




@end

@interface _List (CoreDataGeneratedAccessors)

- (void)addBookmarks:(NSOrderedSet*)value_;
- (void)removeBookmarks:(NSOrderedSet*)value_;
- (void)addBookmarksObject:(Bookmark*)value_;
- (void)removeBookmarksObject:(Bookmark*)value_;

@end

@interface _List (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableOrderedSet*)primitiveBookmarks;
- (void)setPrimitiveBookmarks:(NSMutableOrderedSet*)value;


@end
