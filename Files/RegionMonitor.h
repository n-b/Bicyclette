//
//  RegionMonitor.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@class BicycletteModel;

@interface RegionMonitor : NSObject
- (id)initWithModel:(BicycletteModel*)model;
- (void)startUsingUserLocation;
@end
