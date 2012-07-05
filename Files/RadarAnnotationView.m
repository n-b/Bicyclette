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
        self.bounds = CGRectMake(0, 0, 40, 40);
    }
    return self;
}

- (void) setRadar:(Radar *)radar
{
    [_radar removeObserver:self forKeyPath:@"nearRadius" context:(__bridge void *)([RadarAnnotationView class])];
    [_radar removeObserver:self forKeyPath:@"farRadius" context:(__bridge void *)([RadarAnnotationView class])];
    _radar = radar;
    [_radar addObserver:self forKeyPath:@"nearRadius" options:NSKeyValueObservingOptionInitial context:(__bridge void *)([RadarAnnotationView class])];
    [_radar addObserver:self forKeyPath:@"farRadius" options:NSKeyValueObservingOptionInitial context:(__bridge void *)([RadarAnnotationView class])];
    [self setNeedsDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([RadarAnnotationView class])) {
//        if([keyPath isEqualToString:@"farRadius"])
//            self.bounds = CGRectMake(0, 0, 2*self.radar.farRadius, 2*self.radar.farRadius);
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
    CGContextRef c = UIGraphicsGetCurrentContext();
        
//    CGRect smallRect = CGRectMake(rect.size.width/2-self.radar.nearRadius, rect.size.height/2-self.radar.nearRadius,
//                                  2*self.radar.nearRadius, 2*self.radar.nearRadius);
//    CGContextSetStrokeColorWithColor(c, [UIColor blueColor].CGColor);
//    CGContextSetLineWidth(c, 3);
    CGContextStrokeEllipseInRect(c, rect);
}

@end
