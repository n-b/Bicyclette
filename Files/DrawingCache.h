//
//  DrawingCache.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 24/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "Style.h"

// A common "Drawing" facility to reuse identical images.
@interface DrawingCache : NSObject

// Shape
typedef enum{
    BackgroundShapeRectangle,
    BackgroundShapeRoundedRect,
    BackgroundShapeOval,
}BackgroundShape;

// Border style
typedef enum {
    BorderModeNone,
    BorderModeSolid,
    BorderModeDashes
} BorderMode;

// returns an image drawn with the given params.
// if the method is called again with the identical values, the same object is returned.
- (CGImageRef)sharedAnnotationViewBackgroundLayerWithSize:(CGSize)size
                                                    scale:(CGFloat)scale
                                                    shape:(BackgroundShape)shape
                                               borderMode:(BorderMode)border
                                                baseColor:(UIColor*)baseColor
                                                    value:(NSString*)text
                                                    phase:(CGFloat)phase;

@end
