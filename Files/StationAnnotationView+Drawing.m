//
//  StationAnnotationView+Drawing.
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 24/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "StationAnnotationView+Drawing.h"
#import "Style.h"
#import "UIColor+hsb.h"
#import "BICCGUtilities.h"

typedef enum{
    BackgroundShapeRoundedRect,
    BackgroundShapeOval,
}BackgroundShape;

@implementation StationAnnotationView (Drawing)

+ (CGImageRef)sharedImageWithMode:(StationAnnotationMode)mode
                  backgroundColor:(UIColor*)backgroundColor
                          starred:(BOOL)starred
                            value:(NSString*)text;
{
    NSParameterAssert(backgroundColor);
    NSParameterAssert([NSThread currentThread]==[NSThread mainThread]);
    
    
    // Lookup in cache
    NSString * key = [NSString stringWithFormat:@"image%d_%@_%d_%@", (int)mode, [backgroundColor hsbString], (int)starred, text];
    
    static NSCache * _cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [NSCache new];
    });
    
    CGImageRef result = (__bridge CGImageRef)[_cache objectForKey:key];
    if(result) {
        return result;
    }
    
    // Params
    BackgroundShape shape = mode==StationAnnotationModeBikes? BackgroundShapeOval : BackgroundShapeRoundedRect;
    UIColor * borderColor = starred ? kBicycletteBlue : kAnnotationFrame1Color;
    
    // Create context
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef c = CGBitmapContextCreate(NULL, kStationAnnotationViewSize*scale, kStationAnnotationViewSize*scale, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    CGContextTranslateCTM(c, 0, kStationAnnotationViewSize*scale);
    CGContextScaleCTM(c, 1.0, -1.0);
    
    CGContextScaleCTM(c, scale, scale);
    
    CGRect rect = (CGRect){CGPointZero, CGSizeMake(kStationAnnotationViewSize, kStationAnnotationViewSize)};
    
    // Draw background
    CGContextSaveGState(c);
    
    CGFloat clipMargin = 2.5/scale;
    CGPathRef backgroundPath = [self newPathWithShape:shape inRect:CGRectInset(rect, clipMargin, clipMargin)];
    CGContextAddPath(c, backgroundPath);
    CGContextClip(c);
    CGPathRelease(backgroundPath);
    CGContextSetFillColorWithColor(c, backgroundColor.CGColor);
    CGContextFillRect(c, rect);
    
    CGContextRestoreGState(c);
    
    // Draw border
    CGContextSaveGState(c);
    
    CGContextSetLineWidth(c, 3/scale);
    CGContextSetStrokeColorWithColor(c, borderColor.CGColor);
    CGPathRef borderPath = [self newPathWithShape:shape inRect:CGRectInset(rect, clipMargin, clipMargin)];
    CGContextAddPath(c, borderPath);
    CGContextStrokePath(c);
    CGPathRelease(borderPath);
    
    CGContextRestoreGState(c);
    
    
    UIGraphicsPushContext(c); // Make c the current UIKit drawing context
    // Draw text
    if([text length])
    {
        NSDictionary * attributes = @{NSFontAttributeName:kAnnotationValueFont, NSForegroundColorAttributeName:kAnnotationFrame1Color};
        CGSize textSize = [text sizeWithAttributes:attributes];
        CGPoint point = CGPointMake(CGRectGetMidX(rect)-textSize.width/2, CGRectGetMidY(rect)-textSize.height/2);
        [text drawAtPoint:point withAttributes:attributes];
    }
    UIGraphicsPopContext();
    
    
    CGImageRef image = CGBitmapContextCreateImage(c);
    [_cache setObject:CFBridgingRelease(image) forKey:key];
    CGContextRelease(c);

    return image;
}

// Create a path
+ (CGPathRef) newPathWithShape:(BackgroundShape)shape inRect:(CGRect)rect
{
	CGPathRef path;
    switch (shape) {
        case BackgroundShapeRoundedRect: path = BIC_CGPathCreateWithRoundedRect(rect, 4); break;
        case BackgroundShapeOval: path = CGPathCreateWithEllipseInRect(rect, &CGAffineTransformIdentity); break;
    }
    return path;
}

@end
