//
//  CityRegionUpdateGroup.h
//  Bicyclette
//
//  Created by Nicolas on 10/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "LocalUpdateQueue.h"

@class BicycletteCity;

// Concrete version
@class BicycletteCity;
@interface CityRegionUpdateGroup : NSObject <LocalUpdateGroup>
@property BicycletteCity * city;
- (void) setRegion:(MKCoordinateRegion)region;
@end
