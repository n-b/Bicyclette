//
//  RegionAnnotationView.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "Region.h"
@class LayerCache;

@interface RegionAnnotationView : MKAnnotationView
- (id) initWithRegion:(Region*)region layerCache:(LayerCache*)layerCache;
+ (NSString*) reuseIdentifier;
@end

@interface Region (Mapkit) <MKAnnotation>
@end
