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
    if([self.radar.identifier isEqualToString:RadarIdentifiers.userLocation] || [self.radar.identifier isEqualToString:RadarIdentifiers.screenCenter])
        return;

    CGFloat h;
    switch (self.dragState) {
        case MKAnnotationViewDragStateNone: h = .9; break;
        case MKAnnotationViewDragStateStarting: h = .5; break;
        case MKAnnotationViewDragStateDragging: h = .7; break;
        case MKAnnotationViewDragStateCanceling: h = .2; break;
        case MKAnnotationViewDragStateEnding: default: h = 0;
            break;
    }
    
    [[UIColor colorWithHue:h saturation:.5 brightness:.5 alpha:.5] setFill];
    CGContextFillEllipseInRect(UIGraphicsGetCurrentContext(), rect);
    
    if(self.selected)
    {
        [[UIColor blackColor] setStroke];
        CGContextStrokeEllipseInRect(UIGraphicsGetCurrentContext(), CGRectInset(rect, 2, 2));
    }
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self setNeedsDisplay];
}

- (void) setDragState:(MKAnnotationViewDragState)newDragState animated:(BOOL)animated
{
    [super setDragState:newDragState animated:animated];
    [self setNeedsDisplay];
    
    MKAnnotationViewDragState autoSwithState;
    switch (newDragState) {
        case MKAnnotationViewDragStateStarting: autoSwithState = MKAnnotationViewDragStateDragging; break;
        case MKAnnotationViewDragStateEnding:
        case MKAnnotationViewDragStateCanceling: autoSwithState = MKAnnotationViewDragStateNone; break;
        default: autoSwithState = newDragState; break;
    }
    if(newDragState!=autoSwithState)
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .25 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self setDragState:autoSwithState animated:YES];
        });
    }
}

@end
