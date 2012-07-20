//
//  BicycletteAnnotationView.h
//  Bicyclette
//
//  Created by Nicolas on 20/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "DrawingCache.h"

// Just a small AnnotationView intermediary class with common stuff.
@interface BicycletteAnnotationView : MKAnnotationView

// init
- (id) initWithAnnotation:(id<MKAnnotation>)annotation drawingCache:(DrawingCache*)drawingCache;
@property (readonly) DrawingCache* drawingCache;

// reuse
+ (NSString*) reuseIdentifier;
@end
