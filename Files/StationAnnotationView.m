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

@implementation StationAnnotationView
{
    LayerCache * _layerCache;
    CALayer * _loadingLayer;
}

- (id) initWithStation:(Station*)station layerCache:(LayerCache*)layerCache
{
    self = [super initWithAnnotation:station reuseIdentifier:[[self class] reuseIdentifier]];
    _layerCache = layerCache;
    self.frame = (CGRect){CGPointZero,{kAnnotationViewSize,kAnnotationViewSize}};
    _loadingLayer = [CALayer new];
    _loadingLayer.backgroundColor = [UIColor blueColor].CGColor;
    _loadingLayer.frame = self.bounds;
    _loadingLayer.zPosition = -1;
    [self.layer addSublayer:_loadingLayer];
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @0;
    animation.toValue = @(2*M_PI);
    animation.duration = 3.0f;
    animation.repeatCount = HUGE_VAL;
    [_loadingLayer addAnimation:animation forKey:@"LoadingRotation"];

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
    [self setNeedsDisplay];

    for (NSString * property in [[self class] stationObservedProperties])
        [self.station addObserver:self forKeyPath:property options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void *)([StationAnnotationView class])];
}

- (void) setDisplay:(MapDisplay)display_
{
    _display = display_;
    [self setNeedsDisplay];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    for (NSString * property in [[self class] stationObservedProperties])
        [self.station removeObserver:self forKeyPath:property];
}

- (BOOL) isOpaque
{
    return NO;
}

+ (NSArray*) stationObservedProperties
{
    return @[ @"status_availableValue", @"status_freeValue", @"loading", @"favorite" ];
}


- (void) drawRect:(CGRect)rect
{
    // Prepare Value
    int16_t value;
    if(_display==MapDisplayBikes)
        value = [self station].status_availableValue;
    else
        value = [self station].status_freeValue;

    UIColor * baseColor;
    if(value==0) baseColor = kCriticalValueColor;
    else if(value<4) baseColor = kWarningValueColor;
    else baseColor = kGoodValueColor;

    CGLayerRef cachedLayer = [_layerCache sharedAnnotationViewBackgroundLayerWithSize:CGSizeMake(kAnnotationViewSize, kAnnotationViewSize)
                                                                                    scale:self.layer.contentsScale
                                                                                    shape:_display==MapDisplayBikes? BackgroundShapeOval : BackgroundShapeRoundedRect
                                                                                baseColor:baseColor
                                                                                    value:[NSString stringWithFormat:@"%d",value]];
    CGContextDrawLayerInRect(UIGraphicsGetCurrentContext(), rect, cachedLayer);
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
            _loadingLayer.opacity = [self station].loading ? 1.0 : 0.0;
        }
        else
        {
            if( ! [[change objectForKey:NSKeyValueChangeNewKey] isEqual:[change objectForKey:NSKeyValueChangeOldKey]])
            {
                [self setNeedsDisplay];
                [self pulse];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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
