//
//  CityAnnotationView.m
//  Bicyclette
//
//  Created by Nicolas on 26/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CityAnnotationView.h"
#import "BicycletteCity.h"

@implementation CityAnnotationView

- (BicycletteCity*) city
{
    return (BicycletteCity*)self.annotation;
}

- (BOOL)isOpaque
{
    return NO;
}

- (BOOL)canShowCallout
{
    return YES;
}

- (void) setBounds:(CGRect)bounds
{
    bounds.size.width = MAX(bounds.size.width, 10);
    bounds.size.height = MAX(bounds.size.height, 10);
    
    CGRect b = [self bounds];
    [super setBounds:bounds];
    if(!CGRectEqualToRect(b, bounds))
        [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithHue:.5 saturation:.5 brightness:.5 alpha:.5].CGColor);
    CGContextFillEllipseInRect(ctx, rect);
    CGContextStrokeEllipseInRect(ctx, rect);
}

@end
