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

@interface StationDrawer : NSObject
@property Station* station;
@property MapDisplay display;
@property LayerCache* layerCache;
@end

@interface StationMainDrawer : StationDrawer
@end

@interface StationLoadingDrawer : StationDrawer
@end


@implementation StationAnnotationView
{
    LayerCache * _layerCache;
    StationMainDrawer * _mainDrawer;
    StationLoadingDrawer * _loadingDrawer;
    CALayer * _loadingLayer;
    CALayer * _mainLayer;
}

- (id) initWithStation:(Station*)station layerCache:(LayerCache*)layerCache
{
    self = [super initWithAnnotation:station reuseIdentifier:[[self class] reuseIdentifier]];
    _layerCache = layerCache;
    CGRect rect = {{0,0},{kAnnotationViewSize,kAnnotationViewSize}};

    self.frame = rect;
    
    _mainDrawer = [StationMainDrawer new];
    _mainDrawer.layerCache = _layerCache;
    _mainLayer = [CALayer new];
    _mainLayer.frame = rect;
    _mainLayer.delegate = _mainDrawer;

    [self.layer addSublayer:_mainLayer];
    
    _loadingDrawer = [StationLoadingDrawer new];
    _loadingDrawer.layerCache = _layerCache;
    _loadingLayer = [CALayer new];
    _loadingLayer.frame = rect;
    _loadingLayer.delegate = _loadingDrawer;
    [self.layer addSublayer:_loadingLayer];
    
    return self;
}

+ (NSString*) reuseIdentifier
{
    return NSStringFromClass([StationAnnotationView class]);
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
    
    _mainDrawer.station = annotation;
    _loadingDrawer.station = annotation;
    
    for (NSString * property in [[self class] stationObservedProperties])
        [self.station addObserver:self forKeyPath:property options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void *)([StationAnnotationView class])];
}

- (void) setDisplay:(MapDisplay)display_
{
    _display = display_;
    _mainDrawer.display = self.display;
    _loadingDrawer.display = self.display;
    [_mainLayer setNeedsDisplay];
    [_loadingLayer setNeedsDisplay];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    for (NSString * property in [[self class] stationObservedProperties])
        [self.station removeObserver:self forKeyPath:property];
}

+ (NSArray*) stationObservedProperties
{
    return @[ @"status_availableValue", @"status_freeValue", @"loading", @"favorite" ];
}

- (void) pulse
{
    [UIView animateWithDuration:.3
                     animations:^{ self.transform = CGAffineTransformMakeScale(1.1, 1.1); }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:.3
                                          animations:^{ self.transform = CGAffineTransformIdentity; }
                                          completion:nil];
                     }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([StationAnnotationView class])) {
        if([keyPath isEqual:@"loading"])
        {
            if(self.station.loading)
            {
                CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                animation.fromValue = @0;
                animation.toValue = @(2*M_PI);
                animation.duration = 6.0f;
                animation.repeatCount = HUGE_VAL;
                [_loadingLayer addAnimation:animation forKey:@"LoadingRotation"];
            }
            else
            {
                [_loadingLayer removeAnimationForKey:@"LoadingRotation"];
            }

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

- (void) willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    if(newWindow && _mainLayer.contentsScale!=newWindow.screen.scale)
        _loadingLayer.contentsScale = _mainLayer.contentsScale = newWindow.screen.scale;
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

@implementation StationDrawer
@end

@implementation StationMainDrawer
- (void)displayLayer:(CALayer *)layer
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
    
    CGImageRef image = [self.layerCache sharedAnnotationViewBackgroundLayerWithSize:CGSizeMake(kAnnotationViewSize, kAnnotationViewSize)
                                                                                    scale:layer.contentsScale
                                                                                    shape:self.display==MapDisplayBikes? BackgroundShapeOval : BackgroundShapeRoundedRect
                                                                               borderMode:BorderModeNone
                                                                                baseColor:baseColor
                                                                                    value:[NSString stringWithFormat:@"%d",value]
                                                                                    phase:0];
    layer.contents = (__bridge id)(image);
}
@end

@implementation StationLoadingDrawer
- (void)displayLayer:(CALayer *)layer
{
    CGImageRef image = [self.layerCache sharedAnnotationViewBackgroundLayerWithSize:CGSizeMake(kAnnotationViewSize, kAnnotationViewSize)
                                                                                    scale:layer.contentsScale
                                                                                    shape:self.display==MapDisplayBikes? BackgroundShapeOval : BackgroundShapeRoundedRect
                                                                               borderMode:self.station.loading ? BorderModeDashes : BorderModeSolid
                                                                                baseColor:nil
                                                                                    value:@""
                                                                                    phase:0];
    layer.contents = (__bridge id)(image);
}
@end

