//
//  StationAnnotationView.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "StationAnnotationView.h"
#import "LayerCache.h"

#define kAnnotationViewSize 30

#define kAnnotationFrame1Color [UIColor colorWithHue:0 saturation:.02 brightness:.82 alpha:1]
#define kAnnotationFrame2Color [UIColor colorWithHue:0 saturation:.02 brightness:.07 alpha:1]
#define kAnnotationFrame3Color [UIColor colorWithHue:0 saturation:.02 brightness:.98 alpha:1]

#define kAnnotationBackgoundColor1Bikes [UIColor colorWithHue:0.13 saturation:.62 brightness:.98 alpha:1]
#define kAnnotationBackgoundColor2Bikes [UIColor colorWithHue:0.13 saturation:.62 brightness:.80 alpha:1]

#define kAnnotationBackgoundColor1Parking [UIColor colorWithHue:0.26 saturation:.62 brightness:.98 alpha:1]
#define kAnnotationBackgoundColor2Parking [UIColor colorWithHue:0.26 saturation:.62 brightness:.80 alpha:1]

#define kAnnotationLine1TextColor [UIColor colorWithHue:0 saturation:.02 brightness:.07 alpha:1]
#define kAnnotationLine1TextShadowColor [UIColor colorWithHue:0 saturation:.02 brightness:1 alpha:1]
#define kAnnotationLine1Font [UIFont fontWithName:@"GillSans-Bold" size:20]


@implementation StationAnnotationView
{
    LayerCache * _layerCache;
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
        [self.station addObserver:self forKeyPath:property options:0 context:(__bridge void *)([StationAnnotationView class])];
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
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGLayerRef backgroundLayer = [_layerCache sharedAnnotationViewBackgroundLayerWithSize:CGSizeMake(kAnnotationViewSize, kAnnotationViewSize)
                                                                                    scale:self.layer.contentsScale
                                                                                    shape:BackgroundShapeRoundedRects
                                                                             borderColor1:kAnnotationFrame1Color
                                                                             borderColor2:kAnnotationFrame2Color
                                                                             borderColor3:kAnnotationFrame3Color
                                                                           gradientColor1:_display==MapDisplayBikes? kAnnotationBackgoundColor1Bikes : kAnnotationBackgoundColor1Parking
                                                                           gradientColor2:_display==MapDisplayBikes? kAnnotationBackgoundColor2Bikes : kAnnotationBackgoundColor2Parking];
    CGContextDrawLayerInRect(c, rect, backgroundLayer);
    
    {
        NSString * text;
        if (self.display==MapDisplayBikes)
            text = [NSString stringWithFormat:@"%d",[[self station] status_availableValue]];
        else
            text = [NSString stringWithFormat:@"%d",[[self station] status_freeValue]];

        [kAnnotationLine1TextColor setFill];
        CGContextSetShadowWithColor(c, CGSizeMake(0, .5), 0, [kAnnotationLine1TextShadowColor CGColor]);
        [text drawInRect:rect withFont:kAnnotationLine1Font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([StationAnnotationView class])) {
        [self setNeedsDisplay];
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
