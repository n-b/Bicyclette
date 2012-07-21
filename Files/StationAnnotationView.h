//
//  StationAnnotationView.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteAnnotationView.h"

typedef enum { StationAnnotationModeBikes, StationAnnotationModeParking }  StationAnnotationMode;

@interface StationAnnotationView : BicycletteAnnotationView
@property (nonatomic) StationAnnotationMode mode;
@end
