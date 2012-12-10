//
//  CollectionsAdditions.h
//
//  Created by Nicolas Bouilleaud a long time ago.
//

#import <Foundation/Foundation.h>

@interface NSArray (Additions)

/*
 * KVC related addition : find and return the first object in the array whose value for key *key* is equal to *value*.
 * will return n il if no such object is found.
 */
- (id) firstObjectWithValue:(id)value forKeyPath:(NSString*)key;

/*
 * KVC related addition : find and return the objects in the array whose value for key *key* is equal to *value*.
 * will return an empty array if no such object is found.
 */
- (NSArray*) filteredArrayWithValue:(id)value forKeyPath:(NSString*)key;

/*
 * arrayByRemovingObjectsInArray
 */
- (NSArray*) arrayByRemovingObjectsInArray:(NSArray*)otherArray;

@end


@interface NSSet (Additions)

/*
 * KVC related addition : find and return the first object in the array whose value for key *key* is equal to *value*.
 * will return n il if no such object is found.
 */
- (id) anyObjectWithValue:(id)value forKeyPath:(NSString*)key;

/*
 * KVC related addition : find and return the objects in the array whose value for key *key* is equal to *value*.
 * will return an empty array if no such object is found.
 */
- (NSSet*) filteredSetWithValue:(id)value forKeyPath:(NSString*)key;

@end

