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
#import "NSArrayAdditions.h"
#import "DrawingCache.h"
#import "Style.h"


@interface RadarAnnotationView ()
@property (nonatomic) NSArray * stationsWithinRadarRegion;
@end

@implementation RadarAnnotationView
{
    CALayer * _handleLayer;
}

- (id) initWithAnnotation:(id<MKAnnotation>)annotation drawingCache:(DrawingCache*)drawingCache;
{
    self = [super initWithAnnotation:annotation drawingCache:drawingCache];
    _handleLayer = [CALayer new];
    _handleLayer.bounds = CGRectMake(0,0,kRadarAnnotationHandleSize, kRadarAnnotationHandleSize);
    _handleLayer.actions = @{ @"position" : [NSNull null], @"contents" : [NSNull null] };
    [self.layer addSublayer:_handleLayer];
    return self;
}

- (Radar*) radar
{
    return (Radar*)self.annotation;
}

- (void) setAnnotation:(id<MKAnnotation>)annotation
{
    [self.radar removeObserver:self forKeyPath:@"stationsWithinRadarRegion" context:(__bridge void *)([RadarAnnotationView class])];
    [super setAnnotation:annotation];
    
    self.draggable = self.radar.manualRadarValue;
    self.enabled = self.radar.manualRadarValue;
    if(self.radar==nil)
        self.stationsWithinRadarRegion = nil;
    [self.radar addObserver:self forKeyPath:@"stationsWithinRadarRegion" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                    context:(__bridge void *)([RadarAnnotationView class])];
    [self setNeedsDisplay];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    self.annotation = nil; // stop observing
}

/****************************************************************************/
#pragma mark Data

- (void) setStationsWithinRadarRegion:(NSArray *)newValue
{
    NSArray * oldValue = _stationsWithinRadarRegion;
    NSArray * added = [newValue arrayByRemovingObjectsInArray:oldValue];
    NSArray * removed = [oldValue arrayByRemovingObjectsInArray:newValue];

    // useless now : contents does not depend on which station is being refreshed. Might change.
    for (Station * station in removed)
        [station removeObserver:self forKeyPath:@"isInRefreshQueue" context:(__bridge void *)([RadarAnnotationView class])];

    // useless now : contents does not depend on which station is being refreshed. Might change.
    for (Station * station in added)
        [station addObserver:self forKeyPath:@"isInRefreshQueue" options:0 context:(__bridge void *)([RadarAnnotationView class])];
    
    _stationsWithinRadarRegion = newValue;
}

/****************************************************************************/
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([RadarAnnotationView class])) {
        if([keyPath isEqualToString:@"stationsWithinRadarRegion"])
        {
            id newValue = change[NSKeyValueChangeNewKey];
            self.stationsWithinRadarRegion = newValue != [NSNull null] ? newValue : nil;
        }
        else if([keyPath isEqualToString:@"isInRefreshQueue"])
        {
//            [self setNeedsDisplay]; // useless now : contents does not depend on which station is being refreshed. Might change.
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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
    MKAnnotationViewDragState autoSwithState = newDragState;
    switch (newDragState) {
        case MKAnnotationViewDragStateNone:
            scale = 1.0f;
            offsetY = 0.f;
            break;
        case MKAnnotationViewDragStateStarting:
            scale = 1.05f;
            offsetY = 1.f;
            autoSwithState = MKAnnotationViewDragStateDragging;
            break;
        case MKAnnotationViewDragStateDragging:
            scale = 1.0f;
            offsetY = .5f;
            break;
        case MKAnnotationViewDragStateEnding:
            scale = 1.05f;
            offsetY = 1.f;
            autoSwithState = MKAnnotationViewDragStateNone;
            break;
        case MKAnnotationViewDragStateCanceling:
            scale = 1.0f;
            offsetY = 0.f;
            autoSwithState = MKAnnotationViewDragStateNone;
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

    if(newDragState!=autoSwithState)
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .15 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self setDragState:autoSwithState animated:YES];
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
        _handleLayer.contents =  (id)[self.drawingCache sharedAnnotationViewBackgroundLayerWithSize:_handleLayer.bounds.size
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
    if(self.hidden || self.radar.manualRadarValue==NO)
    {
        self.layer.contents = nil;
        return;
    }

    
    self.layer.contents = (id)[self.drawingCache sharedAnnotationViewBackgroundLayerWithSize:self.bounds.size
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

