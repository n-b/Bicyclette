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
#import "StationAnnotationView+Drawing.h"

@implementation StationAnnotationView
{
    CALayer * _loadingLayer;
    UIButton * _starButton;
}


- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    self.frame = CGRectMake(0,0,kStationAnnotationViewSize,kStationAnnotationViewSize);
    _loadingLayer = [CALayer new];
    _loadingLayer.frame = self.frame;
    [self.layer addSublayer:_loadingLayer];
    
    self.canShowCallout = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stationDidBecomeStale:) name:StationStatusDidBecomeStaleNotificiation object:nil];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (Station*) station
{
    return (Station*)self.annotation;
}

- (void) setAnnotation:(id<MKAnnotation>)annotation
{
    for (NSString * property in [[self class] stationObservedProperties]) {
        [self.station removeObserver:self forKeyPath:property];
    }
    
    [super setAnnotation:annotation];
    
    for (NSString * property in [[self class] stationObservedProperties]) {
        [self.station addObserver:self forKeyPath:property options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void *)([StationAnnotationView class])];
    }
    
    [self setNeedsDisplay];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    for (NSString * property in [[self class] stationObservedProperties]) {
        [self.station removeObserver:self forKeyPath:property];
    }
    self.annotation = nil;
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
        [_starButton setTitle:@"☆ " forState:UIControlStateNormal];
        [_starButton setTitle:@"★ " forState:UIControlStateSelected];
        _starButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:24];
        [_starButton setTitleColor:kBicycletteBlue forState:UIControlStateNormal];
        [_starButton sizeToFit];
        _starButton.selected = self.station.starredValue;
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
    return @[ StationAttributes.status_available, StationAttributes.status_free, StationAttributes.starred ];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([StationAnnotationView class]))
    {
        if([keyPath isEqualToString:StationAttributes.starred])
        {
            _starButton.selected = self.station.starredValue;
        }
        else if(![change[NSKeyValueChangeOldKey] isEqual:change[NSKeyValueChangeNewKey]]) {
            [self setNeedsDisplay];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void) stationDidBecomeStale:(NSNotification*)note
{
    if(note.object==self.station || note.object==nil) {
        [self setNeedsDisplay];
    }
}

/****************************************************************************/
#pragma mark Display

- (void) displayLayer:(CALayer *)layer
{
    // Prepare Value
    UIColor * baseColor;
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
    }
    else
    {
        baseColor = kUnknownValueColor;
        if([self station].status_totalValue!=0)
            text = [NSString stringWithFormat:@"%d",[self station].status_totalValue];
        else
            text = @"-";
    }
    
    self.layer.contents = (id)[StationAnnotationView sharedImageWithMode:self.mode
                                                         backgroundColor:baseColor
                                                                 starred:self.station.starredValue
                                                                   value:text];
}

- (void) drawRect:(CGRect)rect
{
    
}

@end
