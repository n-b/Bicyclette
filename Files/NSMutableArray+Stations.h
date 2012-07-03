//
//  NSMutableArray+Stations.h
//  Bicyclette
//
//  Created by Nicolas on 03/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@interface NSMutableArray (Stations)
- (void) filterStationsWithinDistance:(CLLocationDistance)distance fromLocation:(CLLocation*)location;
- (void) sortStationsNearestFirstFromLocation:(CLLocation*)location;
@end
