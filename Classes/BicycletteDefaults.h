//
//  BicycletteDefaults.h
//  Bicyclette
//
//  Created by Nicolas on 10/04/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface NSUserDefaults(BicycletteDefaults)

@property (readwrite,assign) CLLocation* lastKnownLocation;

@end
