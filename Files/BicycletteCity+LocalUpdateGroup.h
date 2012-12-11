//
//  BicycletteCity+LocalUpdateGroup.h
//  Bicyclette
//
//  Created by Nicolas on 10/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"
#import "Radar.h"
#import "LocalUpdateQueue.h"

// Concrete version
@class BicycletteCity;
@interface LocalUpdateGroup : NSObject <LocalUpdateGroup>
@property BicycletteCity * city;
- (void) setRegion:(MKCoordinateRegion)region;
@end
