//
//  DrawingCache.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 24/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "DrawingCache.h"
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

@implementation DrawingCache
{
    NSCache * _cache;
}

- (id)init
{
    self = [super init];
    if (self) {
        _cache = [NSCache new];
    }
    return self;
}

- (CGImageRef)sharedImageWithSize:(CGSize)size
                            scale:(CGFloat)scale
                            shape:(BackgroundShape)shape
                       borderMode:(BorderMode)border
                        baseColor:(UIColor*)baseColor
                            value:(NSString *)text
                        textColor:(UIColor*)textColor
                            phase:(CGFloat)phase
{
    return [self sharedImageWithSize:size scale:scale shape:shape borderMode:border baseColor:baseColor
                        borderColor1:kAnnotationFrame1Color borderColor2:kAnnotationFrame2Color borderColor3:kAnnotationFrame3Color borderWidth:1
                               value:text textColor:textColor phase:phase];
}

- (CGImageRef)sharedImageWithSize:(CGSize)size
                            scale:(CGFloat)scale
                            shape:(BackgroundShape)shape
                       borderMode:(BorderMode)border
                        baseColor:(UIColor*)baseColor
                     borderColor1:(UIColor*)borderColor1
                     borderColor2:(UIColor*)borderColor2
                     borderColor3:(UIColor*)borderColor3
                      borderWidth:(CGFloat)borderWidth
                            value:(NSString *)text
                        textColor:(UIColor*)textColor
                            phase:(CGFloat)phase
{
    NSString * key = [NSString stringWithFormat:@"image%d_%d_%f_%d_%d_%@_%@_%@_%@_%f_%@_%f",
                      (int)size.width, (int)size.height, (float)scale, (int)shape, (int)border,
                      [baseColor hsbString],
                      [borderColor1 hsbString], [borderColor2 hsbString], [borderColor3 hsbString], borderWidth,
                      text, phase];
    
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
                
                // Draw background
                if(border!=BorderModeNone)
                {
                    CGPathRef path = [self newShape:shape inRect:CGRectInset(rect, .5/scale, .5/scale)];
                    [borderColor1 set];
                    CGContextAddPath(c, path);
                    CGContextDrawPath(c, kCGPathFillStroke);
                    CGPathRelease(path);
                }
                
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
                                                color1:[baseColor colorByAddingBrightness:.1] color2:[baseColor colorByAddingBrightness:-.1]];
                    
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
                        CGFloat expectedDashes = 20; // pixels
                        int count = perimeter/expectedDashes;
                        CGFloat dash = perimeter/(count*2);
                        CGFloat lengths[] = {dash,dash};
                        CGContextSetLineWidth(c, lineWidth/scale);
                        CGPathRef path = [self newShape:shape inRect:CGRectInset(rect, (lineWidth/2)/scale, (lineWidth/2)/scale)];
                        
                        CGContextSetLineDash(c, -phase*dash*2, lengths, sizeof(lengths)/sizeof(CGFloat));
                        [kAnnotationDash1Color setStroke];
                        CGContextAddPath(c, path);
                        CGContextStrokePath(c);
                        
                        CGContextSetLineDash(c, -(phase+.5)*dash*2, lengths, sizeof(lengths)/sizeof(CGFloat));
                        [kAnnotationDash2Color setStroke];
                        CGContextAddPath(c, path);
                        CGContextStrokePath(c);
                        
                        CGPathRelease(path);
                    }
                    else
                    {
                        CGContextSetLineWidth(c, borderWidth/scale);
                        
                        [self drawShape:shape inRect:CGRectInset(rect, borderWidth*1.5/scale, borderWidth*1.5/scale) withStrokeColor:borderColor2];
                        [self drawShape:shape inRect:CGRectInset(rect, borderWidth*2.5/scale, borderWidth*2.5/scale) withStrokeColor:borderColor3];
                    }
                    
                    CGContextRestoreGState(c);
                }
                
                // Draw text
                if(text.length)
                {
                    
                    // Make c the current GraphicsContext
                    [textColor setFill];
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
