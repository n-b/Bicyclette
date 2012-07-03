//
//  RegionAnnotationView.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "Region.h"
@class DrawingCache;

@interface RegionAnnotationView : MKAnnotationView
- (id) initWithRegion:(Region*)region drawingCache:(DrawingCache*)layerCache;
+ (NSString*) reuseIdentifier;
@end

@interface Region (Mapkit) <MKAnnotation>
@end
