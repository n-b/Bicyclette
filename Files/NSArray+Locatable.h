//
//  NSArray+Locatable.h
//  Bicyclette
//
//  Created by Nicolas on 03/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@protocol Locatable <NSObject>
@property (nonatomic, readonly) CLLocation * location;
@end

@interface NSArray (Locatable)
- (instancetype) filteredArrayWithinDistance:(CLLocationDistance)distance fromLocation:(CLLocation*)location;
- (instancetype) sortedArrayByDistanceFromLocation:(CLLocation*)location;
@end
