//
//  Radar.h
//  Bicyclette
//
//  Created by Nicolas on 04/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@interface Radar : NSObject <MKAnnotation>
@property CLLocationCoordinate2D coordinate;
@property CGFloat nearRadius, farRadius;
@end
