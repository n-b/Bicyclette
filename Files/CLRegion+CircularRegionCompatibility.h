//
//  CLRegion+CircularRegionCompatibility.h
//  Bicyclette
//
//  Created by Nicolas on 19/11/2013.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLRegion (CircularRegionCompatibility)
+ (instancetype) bic_compat_circularRegionWithCenter:(CLLocationCoordinate2D)center
                                              radius:(CLLocationDistance)radius
                                          identifier:(NSString *)identifier;

- (CLLocationDistance) bic_compat_radius;
- (CLLocationCoordinate2D) bic_compat_center;

- (BOOL) bic_compat_containsCoordinate:(CLLocationCoordinate2D)coordinate;
@end
