//
//  LayerCache.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 24/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "LayerCache.h"
#import "UIColor+hsb.h"



@implementation LayerCache
{
    NSMutableDictionary * _cache;
}

- (id)init
{
    self = [super init];
    if (self) {
        _cache = [NSMutableDictionary new];
    }
    return self;
}

- (CGLayerRef)sharedAnnotationViewBackgroundLayerWithSize:(CGSize)size
                                                    scale:(CGFloat)scale
                                                    shape:(BackgroundShape)shape
                                             borderColor1:(UIColor*)borderColor1
                                             borderColor2:(UIColor*)borderColor2
                                             borderColor3:(UIColor*)borderColor3
                                           gradientColor1:(UIColor*)gradientColor1
                                           gradientColor2:(UIColor*)gradientColor2
{
    NSString * key = [NSString stringWithFormat:@"background%d%d%f%d%@%@%@%@%@",
                      (int)size.width, (int)size.height, (float)scale, (int)shape,
                      [borderColor1 hsbString], [borderColor2 hsbString], [borderColor2 hsbString],
                      [gradientColor1 hsbString], [gradientColor2 hsbString]];

    CGLayerRef result = (__bridge CGLayerRef)[_cache objectForKey:key];
    if(result) return result;
    @synchronized(self)
    {
        if ([_cache objectForKey:key]==nil)
        {
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef parentContext = UIGraphicsGetCurrentContext();
            
            CGLayerRef tempLayer = CGLayerCreateWithContext(parentContext, CGSizeMake(size.width*scale, size.height*scale), NULL);
            CGContextRef c = CGLayerGetContext(tempLayer);
            CGContextScaleCTM(c, scale, scale);
            
            CGRect rect = (CGRect){CGPointZero, size};
            {
                {
                    CGContextAddEllipseInRect(c, CGRectInset(rect, 1, 1));
                    CGContextClip(c);
                    
                    CGFloat locations[2] = {0,1};
                    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,
                                                                        (__bridge CFArrayRef)(@[(id)[gradientColor1 CGColor],
                                                                                              (id)[gradientColor2 CGColor]]), locations);
                    CGContextDrawLinearGradient(c, gradient,
                                                CGPointZero, CGPointMake(0, rect.size.height),
                                                kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
                    CGGradientRelease(gradient);
                }
                
                {
                    CGContextSetStrokeColorWithColor(c, borderColor1.CGColor);
                    CGContextSetLineWidth(c, .5);
                    CGContextAddEllipseInRect(c, CGRectInset(rect, 1, 1));
                    CGContextDrawPath(c, kCGPathStroke);
                }
                
                {
                    CGContextSetStrokeColorWithColor(c, borderColor2.CGColor);
                    CGContextSetLineWidth(c, .5);
                    CGContextAddEllipseInRect(c, CGRectInset(rect, 1.5, 1.5));
                    CGContextDrawPath(c, kCGPathStroke);
                }
                
                {
                    CGContextSetStrokeColorWithColor(c, borderColor3.CGColor);
                    CGContextSetLineWidth(c, .5);
                    CGContextAddEllipseInRect(c, CGRectInset(rect, 2, 2));
                    CGContextDrawPath(c, kCGPathStroke);
                }
            }

            CGColorSpaceRelease(colorSpace);

            [_cache setObject:CFBridgingRelease(tempLayer) forKey:key];
        }
        return (__bridge CGLayerRef)[_cache objectForKey:key];
    }
}

@end
