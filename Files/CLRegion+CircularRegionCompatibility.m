//
//  CLRegion+CircularRegionCompatibility.m
//  Bicyclette
//
//  Created by Nicolas on 19/11/2013.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "CLRegion+CircularRegionCompatibility.h"

@implementation CLRegion (CircularRegionCompatibility)

+ (instancetype) bic_compat_circularRegionWithCenter:(CLLocationCoordinate2D)center
                                              radius:(CLLocationDistance)radius
                                          identifier:(NSString *)identifier
{
#if TARGET_OS_IPHONE
    return [[CLCircularRegion alloc] initWithCenter:center radius:radius identifier:identifier];
#else
    return [[CLRegion alloc] initCircularRegionWithCenter:center radius:radius identifier:identifier];
#endif
}

- (CLLocationDistance) bic_compat_radius
{
#if TARGET_OS_IPHONE
    return ((CLCircularRegion*)self).radius;
#else
    return self.radius;
#endif
}

- (CLLocationCoordinate2D) bic_compat_center
{
#if TARGET_OS_IPHONE
    return ((CLCircularRegion*)self).center;
#else
    return self.center;
#endif
}

- (BOOL) bic_compat_containsCoordinate:(CLLocationCoordinate2D)coordinate
{
#if TARGET_OS_IPHONE
    return [(CLCircularRegion*)self containsCoordinate:coordinate];
#else
    return [self containsCoordinate:coordinate];
#endif
}
@end
