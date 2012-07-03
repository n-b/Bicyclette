//
//  NSArray+Stations.m
//  Bicyclette
//
//  Created by Nicolas on 03/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "NSArray+Stations.h"
#import "Station.h"


@implementation NSArray (Stations)
- (NSArray*) stationsWithDistance:(CLLocationDistance)distance toLocation:(CLLocation*)location
{    
    return [self filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:
             ^BOOL(Station * station, NSDictionary *bindings){
                 return [location distanceFromLocation:station.location] < distance;
             }]];
}

- (NSArray*) sortedStationsNearestFirstFromLocation:(CLLocation*)location
{
    return [self sortedArrayUsingComparator:
            ^NSComparisonResult(Station * station1, Station * station2) {
                CLLocationDistance d1 = [location distanceFromLocation:station1.location];
                CLLocationDistance d2 = [location distanceFromLocation:station2.location];
                return d1<d2 ? NSOrderedAscending : d1>d2 ? NSOrderedDescending : NSOrderedSame;
            }];
}
@end
