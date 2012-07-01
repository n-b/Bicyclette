//
//  RegionAnnotationView.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "RegionAnnotationView.h"
#import "LayerCache.h"
#import "Style.h"


/****************************************************************************/
#pragma mark -

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
                                                                                    shape:BackgroundShapeRectangle
                                                                               borderMode:BorderModeSolid
                                                                                baseColor:kRegionColor
                                                                                    value:@""];

    
    CGContextDrawLayerInRect(c, rect, backgroundLayer);

    {
        NSString * text = [[self region] number];
        NSString * line1 = [text substringToIndex:2];
        NSString * line2 = [text substringFromIndex:2];

        CGRect rect1, rect2;
        CGRectDivide(CGRectInset(rect, 0, 4), &rect1, &rect2, 10, CGRectMinYEdge);

        [kAnnotationTitleTextColor setFill];
        CGContextSetShadowWithColor(c, CGSizeMake(0, .5), 0, [kAnnotationTitleShadowColor CGColor]);
        [line1 drawInRect:rect1 withFont:kAnnotationTitleFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];

        [kAnnotationDetailTextColor setFill];
        CGContextSetShadowWithColor(c, CGSizeMake(0, .5), 0, [kAnnotationDetailShadowColor CGColor]);
        [line2 drawInRect:rect2 withFont:kAnnotationDetailFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
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
