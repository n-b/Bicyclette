//
//  RadarAnnotationView.m
//  Bicyclette
//
//  Created by Nicolas on 04/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "RadarAnnotationView.h"
#import "Radar.h"
#import "Station.h"
#import "NSArrayAdditions.h"

@interface RadarAnnotationView ()
@property (nonatomic) NSArray * stationsWithinRadarRegion;
@end

@implementation RadarAnnotationView

+ (NSString*) reuseIdentifier
{
    return NSStringFromClass([RadarAnnotationView class]);
}

- (id) initWithRadar:(Radar*)radar;
{
    self = [super initWithAnnotation:radar reuseIdentifier:[[self class] reuseIdentifier]];
    if (self) {
        self.annotation = radar;
    }
    return self;
}

/****************************************************************************/
#pragma mark Data

- (void) prepareForReuse
{
    self.annotation = nil;
}

- (Radar*) radar
{
    return (Radar*)self.annotation;
}

- (void) setAnnotation:(id<MKAnnotation>)annotation
{
    [self.radar removeObserver:self forKeyPath:@"stationsWithinRadarRegion" context:(__bridge void *)([RadarAnnotationView class])];
    [super setAnnotation:annotation];

    self.draggable = self.radar.identifier==nil;
    self.enabled = self.radar.identifier==nil;
    if(self.radar==nil)
        self.stationsWithinRadarRegion = nil;
    [self.radar addObserver:self forKeyPath:@"stationsWithinRadarRegion" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                context:(__bridge void *)([RadarAnnotationView class])];
    [self setNeedsDisplay];
}

- (void) setStationsWithinRadarRegion:(NSArray *)newValue
{
    NSArray * oldValue = _stationsWithinRadarRegion;
    NSArray * added = [newValue arrayByRemovingObjectsInArray:oldValue];
    NSArray * removed = [oldValue arrayByRemovingObjectsInArray:newValue];

    for (Station * station in removed)
        [station removeObserver:self forKeyPath:@"needsRefresh" context:(__bridge void *)([RadarAnnotationView class])];
    
    for (Station * station in added)
        [station addObserver:self forKeyPath:@"needsRefresh" options:0 context:(__bridge void *)([RadarAnnotationView class])];
    
    _stationsWithinRadarRegion = newValue;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([RadarAnnotationView class])) {
        if([keyPath isEqualToString:@"stationsWithinRadarRegion"])
        {
            id newValue = change[NSKeyValueChangeNewKey];
            self.stationsWithinRadarRegion = newValue != [NSNull null] ? newValue : nil;
        }
        else if([keyPath isEqualToString:@"needsRefresh"])
        {
            [self setNeedsDisplay];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/****************************************************************************/
#pragma mark Interaction

- (void) setBounds:(CGRect)bounds
{
    CGRect b = [self bounds];
    [super setBounds:bounds];
    if(!CGRectEqualToRect(b, bounds))
        [self setNeedsDisplay];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self setNeedsDisplay];
}

- (void) setDragState:(MKAnnotationViewDragState)newDragState animated:(BOOL)animated
{
    [super setDragState:newDragState animated:animated];
    [self setNeedsDisplay];

    CGFloat scale = 1.0;

    // Automatically switch to next state after .15 seconds
    MKAnnotationViewDragState autoSwithState = newDragState;
    switch (newDragState) {
        case MKAnnotationViewDragStateNone:
            scale = 1.0f;
            break;
        case MKAnnotationViewDragStateStarting:
            scale = 1.1f;
            autoSwithState = MKAnnotationViewDragStateDragging;
            break;
        case MKAnnotationViewDragStateDragging:
            scale = 1.0f;
            break;
        case MKAnnotationViewDragStateEnding:
            scale = 1.1f;
            autoSwithState = MKAnnotationViewDragStateNone;
            break;
        case MKAnnotationViewDragStateCanceling:
            scale = 1.0f;
            autoSwithState = MKAnnotationViewDragStateNone;
            break;
    }

    void (^animations)(void) = ^{
        self.transform = CGAffineTransformMakeScale(scale, scale);
    };
    
    if(animated)
        [UIView animateWithDuration:.15 animations:animations];
    else
        animations();

    if(newDragState!=autoSwithState)
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .15 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self setDragState:autoSwithState animated:YES];
        });
    }
}

/****************************************************************************/
#pragma mark Drawing

- (BOOL) isOpaque
{
    return NO;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();

    
    CGContextSetLineWidth(c, 1);

    if (self.dragState != MKAnnotationViewDragStateNone || self.selected)
    {
        [[UIColor blackColor] setStroke];
        [[UIColor colorWithWhite:.5 alpha:.3] setFill];
    }
    else if([self.radar.identifier isEqualToString:RadarIdentifiers.userLocation] || [self.radar.identifier isEqualToString:RadarIdentifiers.screenCenter])
    {
        [[UIColor lightGrayColor] setStroke];
        [[UIColor colorWithWhite:.5 alpha:.05] setFill];
    }
    else
    {
        [[UIColor grayColor] setStroke];
        [[UIColor colorWithWhite:.5 alpha:.1] setFill];
    }

    CGContextSetShadow(c, CGSizeMake(1, -1), 1);
    
    CGContextAddEllipseInRect(c, CGRectInset(rect, 2, 2));
    CGContextDrawPath(c, kCGPathFillStroke);
}

@end

