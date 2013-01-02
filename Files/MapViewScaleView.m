//
//  MapViewScaleView.m
//  Bicyclette
//
//  Created by Nicolas on 02/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "MapViewScaleView.h"

@implementation MapViewScaleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);

    // Compute text to display
    NSString * text;
    CGFloat width;
    
    MKMapRect mapRect = [self.mapView visibleMapRect];
    CLLocationDistance meters = MKMetersPerMapPointAtLatitude(self.mapView.region.center.latitude) * mapRect.size.width;
    
    CGFloat scaleMaxSize = self.bounds.size.width;// UI points
    CLLocationDistance distanceInScaleSize = meters/self.mapView.bounds.size.width*scaleMaxSize;
    
    CLLocationDistance scaleMaxDistance = 50000; // In meters
    
    // Compute text to display
    if(distanceInScaleSize>scaleMaxDistance)
    {
        text = nil;
        width = 0;
    }
    else
    {
        double roundDistance = 1.0;
        while (scaleMaxDistance>1) {
            if(distanceInScaleSize>scaleMaxDistance)
            {
                roundDistance = scaleMaxDistance; break;
            }

            if(distanceInScaleSize>scaleMaxDistance/2.0)
            {
                roundDistance = scaleMaxDistance/2.0; break;
            }

            if(distanceInScaleSize>scaleMaxDistance/5.0)
            {
                roundDistance = scaleMaxDistance/5.0;
                break;
            }
            
            scaleMaxDistance /= 10.0;
        }
        
        // Get final values
        width = roundf(self.mapView.bounds.size.width/meters*roundDistance);
        if(roundDistance>1000)
            text = [NSString stringWithFormat:@"%.0f km",roundDistance/1000];
        else
            text = [NSString stringWithFormat:@"%.0f m",roundDistance];
    }
    
    // Draw
    [[UIColor blackColor] setFill];
    [[UIColor whiteColor] setStroke];
    
    CGRect scaleRect, nothing;
    scaleRect = rect;
    
    // Infer edge and text alignment from autoresizingMask
    CGRectEdge edge;
    NSTextAlignment alignment;
    if (self.autoresizingMask & UIViewAutoresizingFlexibleLeftMargin) { // align right
        edge = CGRectMaxXEdge;
        alignment = NSTextAlignmentRight;
    }
    else { // align left
        edge = CGRectMinXEdge;
        alignment = NSTextAlignmentLeft;
    }
    
    // Margins
    scaleRect = CGRectInset(scaleRect, 1, 0);
    CGRectDivide(scaleRect, &nothing, &scaleRect, 1, CGRectMaxYEdge);

    // Contents rect
    CGRectDivide(scaleRect, &scaleRect, &nothing, width, edge);

    // Draw Text
    CGFloat fontSize = 9;
    UIFont * font = [UIFont systemFontOfSize:fontSize];
    CGContextSetTextDrawingMode(ctx, kCGTextStroke);
    CGContextSetLineWidth(ctx, 1);
    CGRect textRect;
    CGRectDivide(scaleRect, &nothing, &textRect, 2, edge);
    [text drawInRect:textRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:alignment];
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    [text drawInRect:textRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:alignment];

    // Draw path
    UIBezierPath * path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(CGRectGetMinX(scaleRect),CGRectGetMaxY(scaleRect)-2)];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(scaleRect),CGRectGetMaxY(scaleRect))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(scaleRect),CGRectGetMaxY(scaleRect))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(scaleRect),CGRectGetMaxY(scaleRect)-2)];
    path.lineWidth = 0;
    CGPathRef p = [path CGPath];
    p = CGPathCreateCopyByStrokingPath(p, NULL, 1, path.lineCapStyle, path.lineJoinStyle, path.miterLimit);
    path = [UIBezierPath bezierPathWithCGPath:p];
    [path stroke];
    [path fill];
    CGPathRelease(p);
}

@end
