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
    BOOL _pulses;
}

- (id) initWithStation:(Station*)station layerCache:(LayerCache*)layerCache
{
    self = [super initWithAnnotation:station reuseIdentifier:[[self class] reuseIdentifier]];
    _layerCache = layerCache;
    self.frame = (CGRect){CGPointZero,{kAnnotationViewSize,kAnnotationViewSize}};
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
        [self.station addObserver:self forKeyPath:property options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void *)([StationAnnotationView class])];
    [self setPulses:[self station].loading];
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
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contents"];
    animation.duration = 0.2;
    [self.layer addAnimation:animation forKey:@"contents"];

    CGContextRef c = UIGraphicsGetCurrentContext();

    UIColor * baseColor;
    int16_t value;
    if(_display==MapDisplayBikes)
        value = [self station].status_availableValue;
    else
        value = [self station].status_freeValue;

    if(value==0) baseColor = kCriticalValueColor;
    else if(value<5) baseColor = kWarningValueColor;
    else baseColor = kGoodValueColor;

    CGLayerRef backgroundLayer = [_layerCache sharedAnnotationViewBackgroundLayerWithSize:CGSizeMake(kAnnotationViewSize, kAnnotationViewSize)
                                                                                    scale:self.layer.contentsScale
                                                                                    shape:_display==MapDisplayBikes? BackgroundShapeOval : BackgroundShapeRoundedRect
                                                                                baseColor:baseColor];
    CGContextDrawLayerInRect(c, rect, backgroundLayer);

    {
        NSString * text;
        if (self.display==MapDisplayBikes)
            text = [NSString stringWithFormat:@"%d",[[self station] status_availableValue]];
        else
            text = [NSString stringWithFormat:@"%d",[[self station] status_freeValue]];

        [kAnnotationValueTextColor setFill];
        CGContextSetShadowWithColor(c, CGSizeMake(0, .5), 0, [kAnnotationValueShadowColor CGColor]);
        CGSize textSize = [text sizeWithFont:kAnnotationValueFont];
		CGPoint point = CGPointMake(CGRectGetMidX(rect)-textSize.width/2, CGRectGetMidY(rect)-textSize.height/2);
        [text drawAtPoint:point withFont:kAnnotationValueFont];
    }
}

- (void) setPulses:(BOOL)pulses
{
    _pulses = pulses;
	if(_pulses) [self pulse];
}

- (void) pulse
{
    [UIView animateWithDuration:.3
                     animations:^{ self.transform = CGAffineTransformMakeScale(1.1, 1.1); }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:.1
                                          animations:^{ self.transform = CGAffineTransformIdentity; }
                                          completion:^(BOOL f) {
                                              if(_pulses) [self pulse];
                                          }];
                     }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([StationAnnotationView class])) {
        if([keyPath isEqual:@"loading"])
        {
			[self setPulses:[self station].loading];
        }
        else
        {
            if( ! [[change objectForKey:NSKeyValueChangeNewKey] isEqual:[change objectForKey:NSKeyValueChangeOldKey]])
                [self setNeedsDisplay];
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
