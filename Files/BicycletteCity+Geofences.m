//
//  BicycletteCity+Geofences.m
//  Bicyclette
//
//  Created by Nicolas @ bou.io on 21/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity+Geofences.h"

@implementation BicycletteCity (Geofences)
- (NSArray*) geofences
{
    return nil;
}
@end


@implementation Geofence (LocalUpdateGroup)

/****************************************************************************/
#pragma mark Locatable

static char kGeoFence_associatedPointsToUpdateKey;
- (void) setPointsToUpdate:(NSArray*)property_ {
    objc_setAssociatedObject(self, &kGeoFence_associatedPointsToUpdateKey, property_, OBJC_ASSOCIATION_RETAIN);
}
- (NSArray *)pointsToUpdate {
    return objc_getAssociatedObject(self, &kGeoFence_associatedPointsToUpdateKey);
}

- (CLLocation*) location
{
    return [[CLLocation alloc] initWithLatitude:self.region.center.latitude longitude:self.region.center.longitude];
}

- (CLLocationDistance) radius
{
    return self.region.radius;
}

@end
