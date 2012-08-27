//
//  RegionAnnotationView.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "Region.h"
#import "RegionAnnotationView.h"
#import "Style.h"


/****************************************************************************/
#pragma mark -

@implementation RegionAnnotationView

- (id) initWithAnnotation:(id<MKAnnotation>)annotation drawingCache:(DrawingCache*)drawingCache
{
    self = [super initWithAnnotation:annotation drawingCache:drawingCache];
    self.frame = (CGRect){CGPointZero,{kRegionAnnotationViewSize,kRegionAnnotationViewSize}};
    return self;
}

- (Region*) region
{
    return (Region*)self.annotation;
}

- (void) setAnnotation:(id<MKAnnotation>)annotation
{
    [self.region removeObserver:self forKeyPath:RegionAttributes.number];
    [super setAnnotation:annotation];
    [self setNeedsDisplay];
    [self.region addObserver:self forKeyPath:RegionAttributes.number options:0 context:(__bridge void *)([RegionAnnotationView class])];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    [self.region removeObserver:self forKeyPath:RegionAttributes.number];
}

/****************************************************************************/
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([RegionAnnotationView class])) {
        [self setNeedsDisplay];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/****************************************************************************/
#pragma mark Drawing

- (BOOL) isOpaque
{
    return NO;
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGImageRef background = [self.drawingCache sharedImageWithSize:CGSizeMake(kRegionAnnotationViewSize, kRegionAnnotationViewSize)
                                                             scale:self.layer.contentsScale
                                                             shape:BackgroundShapeRoundedRect
                                                        borderMode:BorderModeSolid
                                                         baseColor:kRegionColor
                                                      borderColor1:kRegionFrame1Color
                                                      borderColor2:kRegionFrame2Color
                                                      borderColor3:kRegionFrame3Color
                                                       borderWidth:2
                                                             value:@""
                                                             phase:0];
    
    
    CGContextDrawImage(c, rect, background);
    
    {
        NSString * text = [[self region] number];
        NSString * line1 = [text substringToIndex:2];
        NSString * line2 = [text substringFromIndex:2];
        
        CGRect rect1, rect2;
        CGRectDivide(CGRectInset(rect, 0, 2), &rect1, &rect2, 16, CGRectMinYEdge);
        
        [kAnnotationTitleTextColor setFill];
        CGContextSetShadowWithColor(c, CGSizeMake(0, .5), 0, [kAnnotationTitleShadowColor CGColor]);
        [line1 drawInRect:rect1 withFont:kAnnotationTitleFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
        
        [kAnnotationDetailTextColor setFill];
        CGContextSetShadowWithColor(c, CGSizeMake(0, .5), 0, [kAnnotationDetailShadowColor CGColor]);
        [line2 drawInRect:rect2 withFont:kAnnotationDetailFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    }
}

@end
