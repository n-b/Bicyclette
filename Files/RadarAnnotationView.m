//
//  RadarAnnotationView.m
//  Bicyclette
//
//  Created by Nicolas on 04/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "RadarAnnotationView.h"
#import "Radar.h"
#import "Station.h"
#import "CollectionsAdditions.h"
#import "DrawingCache.h"
#import "Style.h"

@implementation RadarAnnotationView
{
    CALayer * _handleLayer;
}

- (id) initWithAnnotation:(id<MKAnnotation>)annotation drawingCache:(DrawingCache*)drawingCache;
{
    self = [super initWithAnnotation:annotation drawingCache:drawingCache];
    if(self!=nil)
    {
        self.draggable = YES;
        self.enabled = YES;
        _handleLayer = [CALayer new];
        _handleLayer.bounds = CGRectMake(0,0,kRadarAnnotationHandleSize, kRadarAnnotationHandleSize);
        _handleLayer.actions = @{ @"position" : [NSNull null], @"contents" : [NSNull null] };
        [self.layer addSublayer:_handleLayer];
    }
    return self;
}

- (Radar*) radar
{
    return (Radar*)self.annotation;
}

/****************************************************************************/
#pragma mark Interaction

- (void) setBounds:(CGRect)bounds
{
    CGRect b = [self bounds];
    [super setBounds:bounds];
    if(!CGRectEqualToRect(b, bounds))
    {
        _handleLayer.position = CGPointMake(CGRectGetMidX(self.layer.bounds), CGRectGetMidY(self.layer.bounds));
        [self setNeedsDisplay];
    }
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self displayHandleLayer];
}

- (void) setDragState:(MKAnnotationViewDragState)newDragState animated:(BOOL)animated
{
    [super setDragState:newDragState animated:animated];
    
    CGFloat scale = 1.0;
    CGFloat offsetY = 0.5;
    
    // Automatically switch to next state after .15 seconds
    MKAnnotationViewDragState autoSwitchState = newDragState;
    switch (newDragState) {
        case MKAnnotationViewDragStateNone:
            scale = 1.0f;
            offsetY = 0.f;
            break;
        case MKAnnotationViewDragStateStarting:
            scale = 1.05f;
            offsetY = 2.5f;
            autoSwitchState = MKAnnotationViewDragStateDragging;
            break;
        case MKAnnotationViewDragStateDragging:
            scale = 1.0f;
            offsetY = 1.5f;
            break;
        case MKAnnotationViewDragStateEnding:
            scale = 1.05f;
            offsetY = 2.5f;
            autoSwitchState = MKAnnotationViewDragStateNone;
            break;
        case MKAnnotationViewDragStateCanceling:
            scale = 1.0f;
            offsetY = 0.f;
            autoSwitchState = MKAnnotationViewDragStateNone;
            break;
    }
    
    void (^animations)(void) = ^{
        self.transform = CGAffineTransformMakeScale(scale, scale);
        _handleLayer.anchorPoint = CGPointMake(.5, offsetY+.5);
        _handleLayer.shadowRadius = 1;
        _handleLayer.shadowOpacity = offsetY != 0.f ? .4f : 0.f;
        _handleLayer.shadowOffset = CGSizeMake(0, offsetY*_handleLayer.bounds.size.height);
    };
    
    if(animated)
        [UIView animateWithDuration:.15 animations:animations];
    else
        animations();
    
    if(newDragState!=autoSwitchState)
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .15 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self setDragState:autoSwitchState animated:YES];
        });
    }
}

/****************************************************************************/
#pragma mark Drawing

- (void) displayHandleLayer
{
    if(!self.draggable)
        _handleLayer.contents = nil;
    else
    {
        UIColor * color = self.selected ? kRadarAnnotationSelectedColor : kRadarAnnotationDefaultColor;
        _handleLayer.contents =  (id)[self.drawingCache sharedImageWithSize:_handleLayer.bounds.size
                                                                      scale:_handleLayer.contentsScale
                                                                      shape:BackgroundShapeOval
                                                                 borderMode:BorderModeSolid
                                                                  baseColor:color
                                                                      value:@""
                                                                      phase:0];
    }
}

- (void)displayLayer:(CALayer *)layer
{
    self.layer.contents = (id)[self.drawingCache sharedImageWithSize:self.bounds.size
                                                               scale:self.layer.contentsScale
                                                               shape:BackgroundShapeOval
                                                          borderMode:BorderModeDashes
                                                           baseColor:nil
                                                               value:@""
                                                               phase:0];
    [self displayHandleLayer];
}

- (void)drawRect:(CGRect)rect
{
    // implemented just so that displayLayer: is called
}

@end

