//
//  CLLocation+Direction.h
//  Bicyclette
//
//  Created by Nicolas on 11/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface CLLocation(Direction)
- (CLLocationDirection) directionToLocation:(CLLocation*)otherLocation;
- (CLLocationDirection) directionFromLocation:(CLLocation*)otherLocation;

- (NSString*) routeDescriptionToLocation:(CLLocation*)otherLocation;
- (NSString*) routeDescriptionFromLocation:(CLLocation*)otherLocation;

@end

@interface NSString (Direction)
+ (id) directionDescription:(CLLocationDirection)direction;
+ (id) directionShortDescription:(CLLocationDirection)direction;
@end
