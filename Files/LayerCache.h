//
//  LayerCache.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 24/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayerCache : NSObject

typedef enum{
    BackgroundShapeRectangle,
    BackgroundShapeRoundedRect,
    BackgroundShapeOval,
}BackgroundShape;

typedef enum {
    BorderModeNone,
    BorderModeSolid,
    BorderModeDashes
} BorderMode;


- (CGImageRef)sharedAnnotationViewBackgroundLayerWithSize:(CGSize)size
                                                    scale:(CGFloat)scale
                                                    shape:(BackgroundShape)shape
                                               borderMode:(BorderMode)border
                                                baseColor:(UIColor*)baseColor
                                                    value:(NSString*)text
                                                    phase:(CGFloat)phase;

@end
