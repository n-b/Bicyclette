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


- (void) setBounds:(CGRect)bounds
{
    bounds.size.width = MAX(bounds.size.width, 10);
    bounds.size.height = MAX(bounds.size.height, 10);
    
    CGRect b = [self bounds];
    [super setBounds:bounds];
    if(!CGRectEqualToRect(b, bounds))
        [self setNeedsDisplay];
}

- (void)displayLayer:(CALayer *)layer
{
    self.layer.contents = (id)[self.drawingCache sharedImageWithSize:self.bounds.size
                                                               scale:self.layer.contentsScale
                                                               shape:BackgroundShapeOval
                                                          borderMode:BorderModeSolid
                                                           baseColor:[UIColor colorWithRed:0 green:1 blue:0 alpha:.4]
                                                               value:@""
                                                               phase:0];
}

- (void)drawRect:(CGRect)rect
{
    // implemented just so that displayLayer: is called
}

@end
