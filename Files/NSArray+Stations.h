//
//  NSArray+Stations.h
//  Bicyclette
//
//  Created by Nicolas on 03/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@interface NSArray (Stations)
- (NSArray*) stationsWithDistance:(CLLocationDistance)distance toLocation:(CLLocation*)location;
- (NSArray*) sortedStationsNearestFirstFromLocation:(CLLocation*)location;
@end
