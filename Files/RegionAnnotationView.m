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
                                                             value:nil
                                                         textColor:nil
                                                             phase:0];
    
    
    CGContextDrawImage(c, rect, background);
    
    {
        NSString * line1 = [[self region] title];
        NSString * line2 = [[self region] subtitle];

        CGRect rect1, rect2;
        CGRectDivide(CGRectInset(rect, 4, 2), &rect1, &rect2, 16, CGRectMinYEdge);
        
        [kAnnotationTitleTextColor setFill];
        CGContextSetShadowWithColor(c, CGSizeMake(0, .5), 0, [kAnnotationTitleShadowColor CGColor]);
        NSMutableParagraphStyle * paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [line1 drawInRect:rect1 withAttributes:@{NSFontAttributeName:kAnnotationTitleFont, NSParagraphStyleAttributeName:paragraphStyle}];
        
        [kAnnotationDetailTextColor setFill];
        CGContextSetShadowWithColor(c, CGSizeMake(0, .5), 0, [kAnnotationDetailShadowColor CGColor]);
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSStringDrawingContext *context = [NSStringDrawingContext new];
        context.minimumScaleFactor = 0.25;
        [line2 drawWithRect:rect2 options:0 attributes:@{NSFontAttributeName:kAnnotationDetailFont, NSParagraphStyleAttributeName:paragraphStyle} context:context];
    }
}

@end
