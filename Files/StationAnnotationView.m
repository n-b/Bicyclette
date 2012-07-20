//
//  StationAnnotationView.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "StationAnnotationView.h"
#import "Station.h"

@implementation StationAnnotationView
{
    CALayer * _loadingLayer;
}

- (id) initWithAnnotation:(id<MKAnnotation>)annotation drawingCache:(DrawingCache*)drawingCache;
{
    self = [super initWithAnnotation:annotation drawingCache:drawingCache];
    self.frame = CGRectMake(0,0,kAnnotationViewSize,kAnnotationViewSize);
    _loadingLayer = [CALayer new];
    _loadingLayer.frame = self.frame;
    [self.layer addSublayer:_loadingLayer];
    return self;
}

- (Station*) station
{
    return (Station*)self.annotation;
}

- (void) setAnnotation:(id<MKAnnotation>)annotation
{
    for (NSString * property in [[self class] stationObservedProperties])
        [self.station removeObserver:self forKeyPath:property];
    
    [super setAnnotation:annotation];
    
    for (NSString * property in [[self class] stationObservedProperties])
        [self.station addObserver:self forKeyPath:property options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void *)([StationAnnotationView class])];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    for (NSString * property in [[self class] stationObservedProperties])
        [self.station removeObserver:self forKeyPath:property];
}

- (void) setDisplay:(MapDisplay)display_
{
    _display = display_;
    [self setNeedsDisplay];
}

/****************************************************************************/
#pragma mark KVO

+ (NSArray*) stationObservedProperties
{
    return @[ StationAttributes.status_available, StationAttributes.status_free, @"needsRefresh", @"loading" ];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([StationAnnotationView class])) {
        if([keyPath isEqual:@"needsRefresh"] || [keyPath isEqual:@"loading"])
        {
            [self displayLoadingLayer];
        }
        else
        {
            [self setNeedsDisplay];
            if(change[NSKeyValueChangeOldKey])
                [self pulse];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/****************************************************************************/
#pragma mark Display

- (void) pulse
{
    [UIView animateWithDuration:.3
                     animations:^{ self.transform = CGAffineTransformMakeScale(1.2, 1.2); }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:.3
                                          animations:^{ self.transform = CGAffineTransformIdentity; }
                                          completion:nil];
                     }];
}

- (void) displayLoadingLayer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    
    if([self station].needsRefresh)
    {
        CGFloat phase = 0;
        if([self station].loading)
        {
            double integral;
            phase = modf([[NSDate date] timeIntervalSinceReferenceDate], &integral);
            phase = floorf(phase*10)/10;
            [self performSelector:_cmd withObject:nil afterDelay:.1];
        }
        _loadingLayer.contents = (id) [self.drawingCache sharedAnnotationViewBackgroundLayerWithSize:CGSizeMake(kAnnotationViewSize, kAnnotationViewSize)
                                                                                               scale:_loadingLayer.contentsScale
                                                                                               shape:self.display==MapDisplayBikes? BackgroundShapeOval : BackgroundShapeRoundedRect
                                                                                          borderMode:BorderModeDashes
                                                                                           baseColor:nil
                                                                                               value:@""
                                                                                               phase:phase];
        
    }
    else
    {
        
        _loadingLayer.contents = nil;
    }
    
}

- (void) displayLayer:(CALayer *)layer
{
    // Prepare Value
    UIColor * baseColor;
    NSString * text;
    if([self station].status_date)
    {
        int16_t value;
        if(self.display==MapDisplayBikes)
            value = [self station].status_availableValue;
        else
            value = [self station].status_freeValue;
        
        if(value==0) baseColor = kCriticalValueColor;
        else if(value<4) baseColor = kWarningValueColor;
        else baseColor = kGoodValueColor;
        
        text = [NSString stringWithFormat:@"%d",value];
    }
    else
    {
        baseColor = kUnknownValueColor;
        text = @"-";
    }
    
    self.layer.contents = (id)[self.drawingCache sharedAnnotationViewBackgroundLayerWithSize:CGSizeMake(kAnnotationViewSize, kAnnotationViewSize)
                                                                                       scale:self.layer.contentsScale
                                                                                       shape:self.display==MapDisplayBikes? BackgroundShapeOval : BackgroundShapeRoundedRect
                                                                                  borderMode:BorderModeSolid
                                                                                   baseColor:baseColor
                                                                                       value:text
                                                                                       phase:0];
    [self displayLoadingLayer];
}

- (void) drawRect:(CGRect)rect
{
    
}

@end
