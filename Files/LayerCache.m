//
//  LayerCache.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 24/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "LayerCache.h"
#import "Style.h"

#import "UIColor+hsb.h"

typedef enum {
    RoundedCornerNone = 0,
    RoundedCornerTopLeft = 1 << 0,
    RoundedCornerTopRight = 1 << 1,
    RoundedCornerTop = RoundedCornerTopLeft | RoundedCornerTopRight,
    RoundedCornerBottomLeft = 1 << 2,
    RoundedCornerBottomRight = 1 << 3,
    RoundedCornerBottom = RoundedCornerBottomLeft | RoundedCornerBottomRight,
    RoundedCornerAll = RoundedCornerTop | RoundedCornerBottom,
} RoundedCorners;

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

- (CGImageRef)sharedAnnotationViewBackgroundLayerWithSize:(CGSize)size
                                                    scale:(CGFloat)scale
                                                    shape:(BackgroundShape)shape
                                               borderMode:(BorderMode)border
                                                baseColor:(UIColor*)baseColor
                                                    value:(NSString *)text
                                                    phase:(CGFloat)phase
{
    NSString * key = [NSString stringWithFormat:@"layer%d_%d_%f_%d_%d_%@_%@_%f",
                      (int)size.width, (int)size.height, (float)scale, (int)shape, (int)border,
                      [baseColor hsbString],text, phase];
    
    CGImageRef result = (__bridge CGImageRef)[_cache objectForKey:key];
    if(result) return result;
    @synchronized(self)
    {
        if ([_cache objectForKey:key]==nil)
        {
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef c = CGBitmapContextCreate(NULL, size.width*scale, size.height*scale, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
            CGColorSpaceRelease(colorSpace);
            
            CGContextTranslateCTM(c, 0, size.height*scale);
            CGContextScaleCTM(c, 1.0, -1.0);

            UIGraphicsPushContext(c); // Make c the current drawing context
            {
                CGContextScaleCTM(c, scale, scale);
                
                CGRect rect = (CGRect){CGPointZero, size};
                
                // Draw gradient
                if(baseColor)
                {
                    CGContextSaveGState(c);
                    
                    CGFloat clipMargin = 2.5/scale;
                    CGPathRef path = [self newShape:shape inRect:CGRectInset(rect, clipMargin, clipMargin)];
                    CGContextAddPath(c, path);
                    CGContextClip(c);
                    CGPathRelease(path);
                    
                    [self drawSimpleGradientFromPoint1:CGPointZero toPoint2:CGPointMake(0, rect.size.height)
                                                color1:baseColor color2:[baseColor colorByAddingBrightness:-.2]];
                    
                    CGContextRestoreGState(c);
                }
                
                // Draw border
                if(border!=BorderModeNone)
                {
                    CGContextSaveGState(c);
                    
                    if(border==BorderModeDashes)
                    {
                        CGFloat lineWidth = 3;
                        CGFloat perimeter = (rect.size.width-lineWidth/2/scale) * M_PI;
                        CGFloat dash = perimeter/24;
                        CGFloat lengths[] = {dash,dash};
                        CGContextSetLineWidth(c, lineWidth/scale);
                        CGPathRef path = [self newShape:shape inRect:CGRectInset(rect, (lineWidth/2)/scale, (lineWidth/2)/scale)];

                        CGContextSetLineDash(c, -phase*dash*2, lengths, sizeof(lengths)/sizeof(CGFloat));
                        [kAnnotationFrame2Color setStroke];
                        CGContextAddPath(c, path);
                        CGContextStrokePath(c);

                        CGContextSetLineDash(c, -(phase+.5)*dash*2, lengths, sizeof(lengths)/sizeof(CGFloat));
                        [[kAnnotationFrame1Color colorWithAlpha:1] setStroke];
                        CGContextAddPath(c, path);
                        CGContextStrokePath(c);

                        CGPathRelease(path);
                    }
                    else
                    {
                        CGContextSetLineWidth(c, 1/scale);

                        [self drawShape:shape inRect:CGRectInset(rect, 0.5/scale, 0.5/scale) withStrokeColor:kAnnotationFrame1Color];
                        [self drawShape:shape inRect:CGRectInset(rect, 1.5/scale, 1.5/scale) withStrokeColor:kAnnotationFrame2Color];
                        [self drawShape:shape inRect:CGRectInset(rect, 2.5/scale, 2.5/scale) withStrokeColor:kAnnotationFrame3Color];
                    }
                    
                    CGContextRestoreGState(c);
                }
                
                // Draw text
                if(text.length)
                {
                    
                    // Make c the current GraphicsContext
                    [kAnnotationValueTextColor setFill];
                    CGContextSetShadowWithColor(c, CGSizeMake(0, -1/scale), 0, [kAnnotationValueShadowColor CGColor]);
                    CGSize textSize = [text sizeWithFont:kAnnotationValueFont];
                    CGPoint point = CGPointMake(CGRectGetMidX(rect)-textSize.width/2, CGRectGetMidY(rect)-textSize.height/2);
                    [text drawAtPoint:point withFont:kAnnotationValueFont];
                    
                }
            }
            UIGraphicsPopContext();
            
            CGImageRef image = CGBitmapContextCreateImage(c);
            [_cache setObject:CFBridgingRelease(image) forKey:key];
            CGContextRelease(c);
        }
        return (__bridge CGImageRef)[_cache objectForKey:key];
    }
}

// Utilities
- (void) drawShape:(BackgroundShape)shape inRect:(CGRect)rect withStrokeColor:(UIColor*)color
{
    [color setStroke];
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGPathRef path = [self newShape:shape inRect:rect];
    CGContextAddPath(c, path);
    CGContextStrokePath(c);
    CGPathRelease(path);
}

- (void) drawSimpleGradientFromPoint1:(CGPoint)point1 toPoint2:(CGPoint)point2 color1:(UIColor*)color1 color2:(UIColor*)color2
{
    CGFloat locations[2] = {0,1};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,
                                                        (__bridge CFArrayRef)(@[(id)[color1 CGColor],
                                                                              (id)[color2 CGColor]]), locations);

    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient, point1, point2, 0);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

// Create a path
- (CGPathRef) newShape:(BackgroundShape)shape inRect:(CGRect)rect
{
	CGPathRef path;
    switch (shape) {
        case BackgroundShapeRectangle: path = CGPathCreateWithRect(rect, &CGAffineTransformIdentity); break;
        case BackgroundShapeRoundedRect: path = [self newPath:rect roundedCorners:RoundedCornerAll cornerRadius:4]; break;
        case BackgroundShapeOval: path = CGPathCreateWithEllipseInRect(rect, &CGAffineTransformIdentity); break;
    }
    return path;
}

// Create a path for a rect with rounded corners
- (CGPathRef) newPath:(CGRect)rect roundedCorners:(RoundedCorners)corners cornerRadius:(CGFloat)cornerRadius
{
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, minx, midy);
    
    if(corners & RoundedCornerTopLeft)
    {
        CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, cornerRadius);
    }
    else
    {
        CGPathAddLineToPoint(path, NULL, minx, miny);
        CGPathAddLineToPoint(path, NULL, midx, miny);
    }
    
    if(corners & RoundedCornerTopRight)
    {
        CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, cornerRadius);
    }
    else
    {
        CGPathAddLineToPoint(path, NULL, maxx, miny);
        CGPathAddLineToPoint(path, NULL, maxx, midy);
    }
    
    if(corners & RoundedCornerBottomRight)
    {
        CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, cornerRadius);
    }
    else
    {
        CGPathAddLineToPoint(path, NULL, maxx, maxy);
        CGPathAddLineToPoint(path, NULL, midx, maxy);
    }
    
    if(corners & RoundedCornerBottomLeft)
    {
        CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, cornerRadius);
    }
    else
    {
        CGPathAddLineToPoint(path, NULL, minx, maxy);
        CGPathAddLineToPoint(path, NULL, minx, midy);
    }
    
    CGPathCloseSubpath(path);
    
    return path;
}

@end
