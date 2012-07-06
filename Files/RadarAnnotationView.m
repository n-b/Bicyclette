//
//  RadarAnnotationView.m
//  Bicyclette
//
//  Created by Nicolas on 04/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "RadarAnnotationView.h"
#import "Radar.h"

@implementation RadarAnnotationView

+ (NSString*) reuseIdentifier
{
    return NSStringFromClass([RadarAnnotationView class]);
}

- (id) initWithRadar:(Radar*)radar;
{
    self = [super initWithAnnotation:radar reuseIdentifier:[[self class] reuseIdentifier]];
    if (self) {
        self.radar = radar;
    }
    return self;
}

- (void) setRadar:(Radar *)radar
{
    [_radar removeObserver:self forKeyPath:@"stationsWithinRange" context:(__bridge void *)([RadarAnnotationView class])];
    _radar = radar;
    self.draggable = self.radar.identifier==nil;
    self.enabled = self.radar.identifier==nil;
    [_radar addObserver:self forKeyPath:@"stationsWithinRange" options:NSKeyValueObservingOptionInitial context:(__bridge void *)([RadarAnnotationView class])];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([RadarAnnotationView class])) {
        [self setNeedsDisplay];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (BOOL) isOpaque
{
    return NO;
}

- (void)drawRect:(CGRect)rect
{
    if([self.radar.identifier isEqualToString:@"userLocationRadar"])
        [[UIColor colorWithHue:.5 saturation:.5 brightness:.5 alpha:.2] setFill];
    else if([self.radar.identifier isEqualToString:@"screenCenterRadar"])
        [[UIColor colorWithHue:0 saturation:.5 brightness:.5 alpha:.2] setFill];
    else
        [[UIColor colorWithHue:0 saturation:0 brightness:.5 alpha:.2] setFill];
    
    CGContextFillEllipseInRect(UIGraphicsGetCurrentContext(), rect);
}

@end
