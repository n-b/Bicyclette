//
//  CityOverlayRenderer.m
//  Bicyclette
//
//  Created by Nicolas on 03/10/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "CityOverlayRenderer.h"
#import "BicycletteCity.h"
#import "Station.h"
#import "Station+Update.h"
#import "Style.h"
#import "BICCGUtilities.h"

@interface CityOverlayRenderer ()
@property (readonly) BicycletteCity * city;
@end

@implementation CityOverlayRenderer

- (BicycletteCity *)city
{
    return (BicycletteCity *)self.overlay;
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{

    // stations will be drawn using a rect whose size depends on the scale
    CGFloat stationRadius = MKRoadWidthAtZoomScale(zoomScale);
    
    // We're going to need a slightly larger rect to draw stations that are just near the border
    CGRect rect = CGRectInset([self rectForMapRect:mapRect], -stationRadius, -stationRadius);
    mapRect = [self mapRectForRect:rect];
    
    // Fetch all the stations in this rect
    NSArray * stations = [self.city stationsWithinRegion:MKCoordinateRegionForMapRect(mapRect)];
    for (Station * station in stations) {
        CGPoint point = [self pointForMapPoint:MKMapPointForCoordinate(station.coordinate)];
        
        UIColor * color;
        if(station.statusDataIsFresh && station.openValue) {
            int16_t value;
            if(self.mode==StationAnnotationModeBikes)
                value = station.status_availableValue;
            else
                value = station.status_freeValue;
            
            if(value==0) color = kCriticalValueColor;
            else if(value<4) color = kWarningValueColor;
            else color = kGoodValueColor;
        } else {
            color = kUnknownValueColor;
        }
        color = [color colorWithAlphaComponent:.8];
        CGContextSetFillColorWithColor(context, color.CGColor);

        CGRect stationRect = CGRectMake(point.x-stationRadius, point.y-stationRadius, stationRadius * 2, stationRadius * 2);
        if(self.mode==StationAnnotationModeBikes) {
            CGContextFillEllipseInRect(context, CGRectIntegral(stationRect));
        } else {
            CGPathRef path = BIC_CGPathCreateWithRoundedRect(stationRect, stationRadius/2);
            CGContextAddPath(context, path);
            CGPathRelease(path);
            CGContextFillPath(context);
        }
    }
}

@end
