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
    [[UIColor colorWithWhite:0 alpha:0.25] setFill];
    UIRectFill(rect);
}

@end
