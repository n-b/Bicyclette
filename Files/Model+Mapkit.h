//
//  Model+Mapkit.h
//  Bicyclette
//
//  Created by Nicolas on 12/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Station.h"
#import "Region.h"

@interface Station (Mapkit) <MKAnnotation>

@end


@interface Region (Mapkit) <MKAnnotation>

@end
