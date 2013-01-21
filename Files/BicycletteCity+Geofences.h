//
//  BicycletteCity+Geofences.h
//  Bicyclette
//
//  Created by Nicolas @ bou.io on 21/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"
#import "GeofencesMonitor.h"

@interface BicycletteCity (Geofences)
@property (readonly) NSArray* geofences;
@end

@interface Geofence (LocalUpdateGroup) <LocalUpdateGroup>
@end
