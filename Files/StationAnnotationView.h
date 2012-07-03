//
//  StationAnnotationView.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "MapVC.h"
#import "Station.h"

@class DrawingCache;

@interface StationAnnotationView : MKAnnotationView

- (id) initWithStation:(Station*)station drawingCache:(DrawingCache*)layerCache;
+ (NSString*) reuseIdentifier;

@property (nonatomic) MapDisplay display;
@end

@interface Station (Mapkit) <MKAnnotation>
@end
