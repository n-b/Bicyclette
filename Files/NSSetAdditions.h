//
//  NSSetAdditions.h
//
//  Created by Nicolas Bouilleaud a long time ago.
//

#import <Foundation/Foundation.h>

@interface NSSet (Additions)

/*
 * KVC related addition : find and return the first object in the array whose value for key *key* is equal to *value*.
 * will return n il if no such object is found.
 */
- (id) anyObjectWithValue:(id)value forKey:(NSString*)key;

/*
 * KVC related addition : find and return the objects in the array whose value for key *key* is equal to *value*.
 * will return an empty array if no such object is found.
 */
- (NSSet*) filteredSetWithValue:(id)value forKey:(NSString*)key;

/*
 * KVC related addition : find and return the objects who return a YES value when the passed selector is sent to them.
 */
- (NSSet*) filteredSetWithSelector:(SEL)aFilterSelector;

/*
 * arrayByRemovingObjectsInArray
 */
- (NSSet*) setByRemovingObjectsInSet:(NSSet*)otherSet;

@end

