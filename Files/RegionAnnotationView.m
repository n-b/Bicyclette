//
//  RegionAnnotationView.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "RegionAnnotationView.h"
#import "LayerCache.h"

/****************************************************************************/
#pragma mark -

#define kAnnotationViewSize 30

#define kAnnotationFrame1Color [UIColor colorWithHue:0 saturation:.02 brightness:.82 alpha:1]
#define kAnnotationFrame2Color [UIColor colorWithHue:0 saturation:.02 brightness:.07 alpha:1]
#define kAnnotationFrame3Color [UIColor colorWithHue:0 saturation:.02 brightness:.98 alpha:1]
#define kAnnotationBackgoundColor1 [UIColor colorWithHue:0 saturation:.02 brightness:.98 alpha:1]
#define kAnnotationBackgoundColor2 [UIColor colorWithHue:0 saturation:.02 brightness:.80 alpha:1]

#define kAnnotationLine1TextColor [UIColor colorWithHue:0 saturation:.02 brightness:.07 alpha:1]
#define kAnnotationLine1TextShadowColor [UIColor colorWithHue:0 saturation:.02 brightness:1 alpha:1]
#define kAnnotationLine1Font [UIFont fontWithName:@"GillSans-Bold" size:10]
#define kAnnotationLine2TextColor [UIColor colorWithHue:0 saturation:.02 brightness:.07 alpha:1]
#define kAnnotationLine2TextShadowColor [UIColor colorWithHue:0 saturation:.02 brightness:1 alpha:1]
#define kAnnotationLine2Font [UIFont fontWithName:@"GillSans" size:10]

@implementation RegionAnnotationView
{
    LayerCache * _layerCache;
}

- (id) initWithRegion:(Region*)region layerCache:(LayerCache*)layerCache
{
    self = [super initWithAnnotation:region reuseIdentifier:[[self class] reuseIdentifier]];
    _layerCache = layerCache;
    self.frame = (CGRect){CGPointZero,{kAnnotationViewSize,kAnnotationViewSize}};
    return self;
}

+ (NSString*) reuseIdentifier
{
    return NSStringFromClass([RegionAnnotationView class]);
}

- (Region*) region
{
    return (Region*)self.annotation;
}

- (void) setAnnotation:(id<MKAnnotation>)annotation
{
    [self.region removeObserver:self forKeyPath:@"number"];
    [super setAnnotation:annotation];
    [self setNeedsDisplay];
    [self.region addObserver:self forKeyPath:@"number" options:0 context:(__bridge void *)([RegionAnnotationView class])];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    [self.region removeObserver:self forKeyPath:@"number"];
}

- (BOOL) isOpaque
{
    return NO;
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();

    CGLayerRef backgroundLayer = [_layerCache sharedAnnotationViewBackgroundLayerWithSize:CGSizeMake(kAnnotationViewSize, kAnnotationViewSize)
                                                                                    scale:self.layer.contentsScale
                                                                                    shape:BackgroundShapeOval
                                                                             borderColor1:kAnnotationFrame1Color
                                                                             borderColor2:kAnnotationFrame2Color
                                                                             borderColor3:kAnnotationFrame3Color
                                                                           gradientColor1:kAnnotationBackgoundColor1
                                                                           gradientColor2:kAnnotationBackgoundColor2];

    
    CGContextDrawLayerInRect(c, rect, backgroundLayer);

    {
        NSString * text = [[self region] number];
        NSString * line1 = [text substringToIndex:2];
        NSString * line2 = [text substringFromIndex:2];

        CGRect rect1, rect2;
        CGRectDivide(CGRectInset(rect, 0, 4), &rect1, &rect2, 10, CGRectMinYEdge);

        [kAnnotationLine1TextColor setFill];
        CGContextSetShadowWithColor(c, CGSizeMake(0, .5), 0, [kAnnotationLine1TextShadowColor CGColor]);
        [line1 drawInRect:rect1 withFont:kAnnotationLine1Font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];

        [kAnnotationLine2TextColor setFill];
        CGContextSetShadowWithColor(c, CGSizeMake(0, .5), 0, [kAnnotationLine2TextShadowColor CGColor]);
        [line2 drawInRect:rect2 withFont:kAnnotationLine2Font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([RegionAnnotationView class])) {
        [self setNeedsDisplay];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

/****************************************************************************/
#pragma mark -

@implementation Region (Mapkit) 

- (CLLocationCoordinate2D) coordinate
{
	return self.coordinateRegion.center;
}

- (NSString *)title
{
	return self.name;
}

- (NSString *)subtitle
{
	return [NSString stringWithFormat:NSLocalizedString(@"%d stations",@""),self.stations.count];
}

@end
