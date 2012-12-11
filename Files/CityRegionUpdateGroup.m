//
//  CityRegionUpdateGroup.m
//  Bicyclette
//
//  Created by Nicolas on 10/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CityRegionUpdateGroup.h"
#import "BicycletteCity.h"

@interface CityRegionUpdateGroup ()
@property MKCoordinateRegion region;
@end

@implementation CityRegionUpdateGroup
- (CLLocation *) location
{
    return [[CLLocation alloc] initWithLatitude:self.region.center.latitude longitude:self.region.center.longitude];
}
- (NSArray*) pointsToUpdate
{
    return [self.city stationsWithinRegion:self.region];
}
+ (NSSet *)keyPathsForValuesAffectingPointsToUpdate
{
    return [NSSet setWithObjects:@"city",@"region", nil];
}
@end
