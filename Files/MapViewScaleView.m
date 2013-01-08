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

static double RoundedValue(double value)
{
    NSCAssert(value<10000.0 && value>1.0, nil);
    double maxRoundedValue = 10000.0;
    while (maxRoundedValue>1) {
        if(value>maxRoundedValue)
            return maxRoundedValue;
        if(value>maxRoundedValue/2.0)
            return maxRoundedValue/2.0;
        if(value>maxRoundedValue/5.0)
            return maxRoundedValue/5.0;
        maxRoundedValue /= 10.0;
    }
    return 1.0;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);

    // Compute text to display
    MKMapRect mapRect = [self.mapView visibleMapRect];
    CLLocationDistance meters = MKMetersPerMapPointAtLatitude(self.mapView.region.center.latitude) * mapRect.size.width;
    
    CGFloat scaleMaxSize = self.bounds.size.width;// UI points
    CLLocationDistance distanceInScaleSize = meters/self.mapView.bounds.size.width*scaleMaxSize;
    CLLocationDistance scaleMaxDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"MapViewScaleView.MaxDistance"]; // In meters
    
    // Compute text to display
    if(distanceInScaleSize>scaleMaxDistance)
        return;
    
    NSString * unit;
    double ratio;
    BOOL useMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
    if(useMetric)
    {
        if(distanceInScaleSize>1000){ // m in km
            ratio = 1000;
            unit = @"km";
        }
        else{
            ratio = 1;
            unit = @"m";
        }
    }
    else
    {
        if(distanceInScaleSize>1609.344){ // m in mi
            ratio = 1609.344;  // m in mi
            unit = @"mi.";
        }
        else{
            ratio = 0.3048; // m in ft
            unit = @"ft.";
        }
    }
    double roundDistance = RoundedValue(distanceInScaleSize/ratio);
    
    // Get final values
    CGFloat width = roundf(self.mapView.bounds.size.width/meters*roundDistance*ratio);
    NSString * text = [NSString stringWithFormat:@"%.0f %@",roundDistance, unit];
    
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
