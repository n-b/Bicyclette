//
//  StationAnnotationView.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "StationAnnotationView.h"
#import "LayerCache.h"
#import "Style.h"

@interface StationLayerDisplayBounce : NSObject
{
@package
    StationAnnotationView* annotationView;
}
@end

/****************************************************************************/
#pragma mark -

@implementation StationAnnotationView
{
    StationLayerDisplayBounce* _bounce;
    LayerCache * _layerCache;
    CALayer * _loadingLayer;
    CALayer * _mainLayer;
}

- (id) initWithStation:(Station*)station layerCache:(LayerCache*)layerCache
{
    self = [super initWithAnnotation:station reuseIdentifier:[[self class] reuseIdentifier]];
    _layerCache = layerCache;

    CGRect rect = {{0,0},{kAnnotationViewSize,kAnnotationViewSize}};
    self.frame = rect;

    _bounce = [StationLayerDisplayBounce new];
    _bounce->annotationView = self;

    _mainLayer = [CALayer new];
    _mainLayer.frame = rect;
    _mainLayer.delegate = _bounce;
    [self.layer addSublayer:_mainLayer];
    
    _loadingLayer = [CALayer new];
    _loadingLayer.frame = rect;
    _loadingLayer.delegate = _bounce;
    [self.layer addSublayer:_loadingLayer];
    
    return self;
}

+ (NSString*) reuseIdentifier
{
    return NSStringFromClass([StationAnnotationView class]);
}

- (void) willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    if(newWindow && _mainLayer.contentsScale!=newWindow.screen.scale)
        _loadingLayer.contentsScale = _mainLayer.contentsScale = newWindow.screen.scale;
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    for (NSString * property in [[self class] stationObservedProperties])
        [self.station removeObserver:self forKeyPath:property];
}

+ (NSArray*) stationObservedProperties
{
    return @[ @"status_availableValue", @"status_freeValue", @"refreshing", @"loading", @"favorite" ];
}

/****************************************************************************/
#pragma mark Setters

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

- (void) setDisplay:(MapDisplay)display_
{
    _display = display_;
    [_mainLayer setNeedsDisplay];
    [_loadingLayer setNeedsDisplay];
    [_loadingLayer setNeedsDisplay];
}

/****************************************************************************/
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([StationAnnotationView class])) {
        if([keyPath isEqual:@"refreshing"] || [keyPath isEqual:@"loading"])
        {
            [_loadingLayer setNeedsDisplay];
        }
        else
        {
            if( ! [[change objectForKey:NSKeyValueChangeNewKey] isEqual:[change objectForKey:NSKeyValueChangeOldKey]])
            {
                [_mainLayer setNeedsDisplay];
                if([change objectForKey:NSKeyValueChangeOldKey])
                    [self pulse];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/****************************************************************************/
#pragma mark Display

- (void) bounceDisplayLayer:(CALayer *)layer
{
    if(layer==_mainLayer) [self displayMainLayer];
    else [self displayLoadingLayer];
}

- (void) displayMainLayer
{
    // Prepare Value
    int16_t value;
    if(self.display==MapDisplayBikes)
        value = [self station].status_availableValue;
    else
        value = [self station].status_freeValue;

    UIColor * baseColor;
    if(value==0) baseColor = kCriticalValueColor;
    else if(value<4) baseColor = kWarningValueColor;
    else baseColor = kGoodValueColor;

    CGImageRef image = [_layerCache sharedAnnotationViewBackgroundLayerWithSize:CGSizeMake(kAnnotationViewSize, kAnnotationViewSize)
                                                                              scale:_mainLayer.contentsScale
                                                                              shape:self.display==MapDisplayBikes? BackgroundShapeOval : BackgroundShapeRoundedRect
                                                                         borderMode:BorderModeSolid
                                                                          baseColor:baseColor
                                                                              value:[NSString stringWithFormat:@"%d",value]
                                                                              phase:0];
    _mainLayer.contents = (__bridge id)(image);
}

- (void) displayLoadingLayer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];

    if([self station].refreshing)
    {
        CGFloat phase = 0;
        if([self station].loading)
        {
            double integral;
            phase = modf([[NSDate date] timeIntervalSinceReferenceDate], &integral);
            phase = floorf(phase*10)/10;
            [self performSelector:_cmd withObject:nil afterDelay:.1];
        }
        CGImageRef image = [_layerCache sharedAnnotationViewBackgroundLayerWithSize:CGSizeMake(kAnnotationViewSize, kAnnotationViewSize)
                                                                              scale:_loadingLayer.contentsScale
                                                                              shape:self.display==MapDisplayBikes? BackgroundShapeOval : BackgroundShapeRoundedRect
                                                                         borderMode:BorderModeDashes
                                                                          baseColor:nil
                                                                              value:@""
                                                                              phase:phase];
        _loadingLayer.contents = (__bridge id)(image);

    }
    else
    {

        _loadingLayer.contents = nil;
    }

}

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


@end

/****************************************************************************/
#pragma mark -

@implementation Station (Mapkit)

- (CLLocationCoordinate2D) coordinate
{
	return self.location.coordinate;
}

@end

/****************************************************************************/
#pragma mark -


@implementation StationLayerDisplayBounce
- (void) displayLayer:(CALayer *)layer
{
    [self->annotationView bounceDisplayLayer:layer];
}
@end
