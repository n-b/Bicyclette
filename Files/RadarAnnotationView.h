//
//  RadarAnnotationView.h
//  Bicyclette
//
//  Created by Nicolas on 04/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@class Radar;
@class DrawingCache;

@interface RadarAnnotationView : MKAnnotationView

+ (NSString*) reuseIdentifier;
- (id) initWithRadar:(Radar*)radar drawingCache:(DrawingCache*)drawingCache;

@end
