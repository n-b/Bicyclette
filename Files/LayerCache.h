//
//  LayerCache.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 24/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayerCache : NSObject
typedef enum
{
    BackgroundShapeRectangle,
    BackgroundShapeRoundedRect,
    BackgroundShapeOval,
}BackgroundShape;

- (CGLayerRef)sharedAnnotationViewBackgroundLayerWithSize:(CGSize)size
                                                    scale:(CGFloat)scale
                                                    shape:(BackgroundShape)shape
                                                baseColor:(UIColor*)baseColor;
@end
