//
//  NSArray+Locatable.m
//  Bicyclette
//
//  Created by Nicolas on 03/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "NSArray+Locatable.h"


@implementation NSArray (Locatable)
- (instancetype) filteredArrayWithinDistance:(CLLocationDistance)distance fromLocation:(CLLocation*)location
{
    return [self filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:
             ^BOOL(id<Locatable> locatable, NSDictionary *bindings){
                 return location && [location distanceFromLocation:locatable.location] < distance;
             }]];
}

- (instancetype) sortedArrayByDistanceFromLocation:(CLLocation*)location
{
    return [self sortedArrayUsingComparator:
            ^NSComparisonResult(id<Locatable> l1, id<Locatable> l2) {
                CLLocationDistance d1 = [location distanceFromLocation:l1.location];
                CLLocationDistance d2 = [location distanceFromLocation:l2.location];
                return d1<d2 ? NSOrderedAscending : d1>d2 ? NSOrderedDescending : NSOrderedSame;
            }];
}
@end
