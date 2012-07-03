//
//  NSMutableArray+Stations.m
//  Bicyclette
//
//  Created by Nicolas on 03/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "NSMutableArray+Stations.h"
#import "Station.h"


@implementation NSMutableArray (Stations)
- (void) filterStationsWithinDistance:(CLLocationDistance)distance fromLocation:(CLLocation*)location
{
    [self filterUsingPredicate:
     [NSPredicate predicateWithBlock:
      ^BOOL(Station * station, NSDictionary *bindings){
          return [location distanceFromLocation:station.location] < distance;
      }]];
}

- (void) sortStationsNearestFirstFromLocation:(CLLocation*)location
{
    [self sortUsingComparator:
     ^NSComparisonResult(Station * station1, Station * station2) {
         CLLocationDistance d1 = [location distanceFromLocation:station1.location];
         CLLocationDistance d2 = [location distanceFromLocation:station2.location];
         return d1<d2 ? NSOrderedAscending : d1>d2 ? NSOrderedDescending : NSOrderedSame;
     }];
}
@end
