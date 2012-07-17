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

static CGRect CGRectMakeCentered(CGRect containingRect, float width, float height)
{
	float x = containingRect.size.width/2.0 - width/2.0;
	float y = containingRect.size.height/2.0 - height/2.0;
    
	return CGRectMake(x, y, width, height);
}

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

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self setNeedsDisplay];
}

- (void) setDragState:(MKAnnotationViewDragState)newDragState animated:(BOOL)animated
{
    [super setDragState:newDragState animated:animated];
    [self setNeedsDisplay];
    
    MKAnnotationViewDragState autoSwithState;
    switch (newDragState) {
        case MKAnnotationViewDragStateStarting: autoSwithState = MKAnnotationViewDragStateDragging; break;
        case MKAnnotationViewDragStateEnding:
        case MKAnnotationViewDragStateCanceling: autoSwithState = MKAnnotationViewDragStateNone; break;
        default: autoSwithState = newDragState; break;
    }
    if(newDragState!=autoSwithState)
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .25 * NSEC_PER_SEC);
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
    CGContextClearRect(c, rect);
//    if([self.radar.identifier isEqualToString:RadarIdentifiers.userLocation] || [self.radar.identifier isEqualToString:RadarIdentifiers.screenCenter])
//        return;

    CGFloat h;
    switch (self.dragState) {
        case MKAnnotationViewDragStateNone: h = .9; break;
        case MKAnnotationViewDragStateStarting: h = .5; break;
        case MKAnnotationViewDragStateDragging: h = .7; break;
        case MKAnnotationViewDragStateCanceling: h = .2; break;
        case MKAnnotationViewDragStateEnding: default: h = 0;
            break;
    }
    
    [[UIColor colorWithHue:h saturation:.5 brightness:.5 alpha:.5] setFill];
    CGContextFillEllipseInRect(c, rect);
    
    [[UIColor blackColor] setStroke];
    if(self.selected)
        CGContextStrokeEllipseInRect(c, CGRectInset(rect, 2, 2));

    
    NSArray * refreshingStations = [self.stationsWithinRadarRegion filteredArrayWithValue:@YES forKey:@"needsRefresh"];
    NSString * test = [NSString stringWithFormat:@"%@/%@", @([refreshingStations count]), @([self.stationsWithinRadarRegion count])];
    [test drawInRect:rect withFont:[UIFont systemFontOfSize:20]];
    
    if ([refreshingStations count])
    {
        CLLocationDistance neareastDistance = [[[refreshingStations objectAtIndex:0] location] distanceFromLocation:[[CLLocation alloc] initWithLatitude:self.radar.latitudeValue longitude:self.radar.longitudeValue]];
        CLLocationDistance farthestDistance = [[[refreshingStations lastObject] location] distanceFromLocation:[[CLLocation alloc] initWithLatitude:self.radar.latitudeValue longitude:self.radar.longitudeValue]];
        
        CLLocationDistance radarDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadarDistance"];
        CGFloat nearestDiameter = neareastDistance * rect.size.width / radarDistance;
        CGFloat farthestDiameter = farthestDistance * rect.size.width / radarDistance;
        
        CGContextStrokeEllipseInRect(c, CGRectMakeCentered(rect, nearestDiameter, nearestDiameter));
        CGContextStrokeEllipseInRect(c, CGRectMakeCentered(rect, farthestDiameter, farthestDiameter));
    }
}

@end

