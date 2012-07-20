//
//  MKMapView+GoogleLogo.m
//  Bicyclette
//
//  Created by Nicolas on 20/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "MKMapView+GoogleLogo.h"

@implementation MKMapView (GoogleLogo)
- (UIImageView*) googleLogo {
    UIImageView *imgView = nil;
    for (UIView *subview in self.subviews) {
        if ([subview isMemberOfClass:[UIImageView class]]) {
            imgView = (UIImageView*)subview;
            break;
        }
    }
    return imgView;
}
@end
