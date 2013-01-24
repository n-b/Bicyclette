//
//  StationAnnotationView.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "StationAnnotationView.h"
#import "Station.h"
#import "Station+Update.h"

@implementation StationAnnotationView
{
    CALayer * _loadingLayer;
    UIButton * _starButton;
}

- (id) initWithAnnotation:(id<MKAnnotation>)annotation drawingCache:(DrawingCache*)drawingCache;
{
    self = [super initWithAnnotation:annotation drawingCache:drawingCache];
    self.frame = CGRectMake(0,0,kStationAnnotationViewSize,kStationAnnotationViewSize);
    _loadingLayer = [CALayer new];
    _loadingLayer.frame = self.frame;
    [self.layer addSublayer:_loadingLayer];
    
    self.canShowCallout = YES;
    
    return self;
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
    
    for (NSString * property in [[self class] stationObservedProperties])
        [self.station addObserver:self forKeyPath:property options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void *)([StationAnnotationView class])];

}

- (void) prepareForReuse
{
    [super prepareForReuse];
    for (NSString * property in [[self class] stationObservedProperties])
        [self.station removeObserver:self forKeyPath:property];
}

- (void) setMode:(StationAnnotationMode)mode_
{
    _mode = mode_;
    [self setNeedsDisplay];
}

/****************************************************************************/
#pragma mark Favorites

- (UIButton*) starButton
{
    if(_starButton==nil)
    {
        _starButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_starButton setTitle:@"☆" forState:UIControlStateNormal];
        [_starButton setTitle:@"★" forState:UIControlStateSelected];
        _starButton.titleLabel.font = [UIFont systemFontOfSize:24];
        [_starButton setTitleColor:[UIColor colorWithWhite:1 alpha:.9] forState:UIControlStateNormal];
        [_starButton setTitleShadowColor:[UIColor colorWithWhite:.2 alpha:1] forState:UIControlStateNormal];
        _starButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [_starButton sizeToFit];
    }
    return _starButton;
}

- (UIView *)rightCalloutAccessoryView
{
    return self.starButton;
}

/****************************************************************************/
#pragma mark KVO

+ (NSArray*) stationObservedProperties
{
    return @[ StationAttributes.status_available, StationAttributes.status_free, StationAttributes.starred, @"statusDataIsFresh" ];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([StationAnnotationView class]))
    {
        if([keyPath isEqualToString:StationAttributes.starred])
        {
            self.starButton.selected = self.station.starredValue;
        }
        else
        {
            [self setNeedsDisplay];
            if(change[NSKeyValueChangeOldKey] && ![change[NSKeyValueChangeOldKey] isEqual:change[NSKeyValueChangeNewKey]])
                [self pulse];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/****************************************************************************/
#pragma mark Display

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

- (void) displayLayer:(CALayer *)layer
{
    // Prepare Value
    UIColor * baseColor, * textColor;
    NSString * text;

    if([[self station] statusDataIsFresh] && [[self station] openValue])
    {
        int16_t value;
        if(self.mode==StationAnnotationModeBikes)
            value = [self station].status_availableValue;
        else
            value = [self station].status_freeValue;
        
        if(value==0) baseColor = kCriticalValueColor;
        else if(value<4) baseColor = kWarningValueColor;
        else baseColor = kGoodValueColor;
        
        text = [NSString stringWithFormat:@"%d",value];
        textColor = kAnnotationValueTextColor;
    }
    else
    {
        baseColor = kUnknownValueColor;
        if([self station].status_totalValue!=0)
            text = [NSString stringWithFormat:@"%d",[self station].status_totalValue];
        else
            text = @"-";
        textColor = kAnnotationValueTextColorAlt;
    }
        
    self.layer.contents = (id)[self.drawingCache sharedImageWithSize:CGSizeMake(kStationAnnotationViewSize, kStationAnnotationViewSize)
                                                               scale:self.layer.contentsScale
                                                               shape:self.mode==StationAnnotationModeBikes? BackgroundShapeOval : BackgroundShapeRoundedRect
                                                          borderMode:[[self station] starredValue]? BorderModeDashes : BorderModeSolid
                                                           baseColor:baseColor
                                                               value:text
                                                           textColor:textColor
                                                               phase:0];
}

- (void) drawRect:(CGRect)rect
{
    
}

@end
