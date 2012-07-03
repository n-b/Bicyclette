//
//  RadarAnnotationView.h
//  Bicyclette
//
//  Created by Nicolas on 04/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Radar;

@interface RadarAnnotationView : MKAnnotationView
+ (NSString*) reuseIdentifier;
- (id) initWithRadar:(Radar*)radar;
@property (nonatomic) Radar * radar;
@end
