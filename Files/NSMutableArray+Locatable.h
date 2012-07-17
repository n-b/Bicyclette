//
//  NSMutableArray+Locatable.h
//  Bicyclette
//
//  Created by Nicolas on 03/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "Station.h"
#import "Radar.h"

@protocol Locatable <NSObject>
@property (readonly) CLLocation * location;
@end

@interface NSMutableArray (Locatable)
- (void) filterWithinDistance:(CLLocationDistance)distance fromLocation:(CLLocation*)location;
- (void) sortByDistanceFromLocation:(CLLocation*)location;
@end

@interface Station (Locatable)
@end

@interface Radar (Locatable)
@end
