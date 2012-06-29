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
                                             borderColor1:(UIColor*)borderColor1
                                             borderColor2:(UIColor*)borderColor2
                                             borderColor3:(UIColor*)borderColor3
                                           gradientColor1:(UIColor*)gradientColor1
                                           gradientColor2:(UIColor*)gradientColor2;
@end
