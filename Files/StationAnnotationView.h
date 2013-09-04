//
//  StationAnnotationView.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@class Station;

@interface StationAnnotationView : MKAnnotationView

typedef NS_ENUM(NSInteger, StationAnnotationMode)
{
    StationAnnotationModeBikes,
    StationAnnotationModeParking
};

@property (nonatomic) StationAnnotationMode mode;
@end
