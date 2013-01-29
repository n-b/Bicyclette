
//
//  MKMapView+AttributionLogo.m
//  Bicyclette
//
//  Created by Nicolas on 20/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "MKMapView+AttributionLogo.h"

@implementation MKMapView (AttributionLogo)

- (void) relocateAttributionLogoIfNecessary
{
#if SCREENSHOTS
    // Debug for screenshot (Default.png)
    {
        self.googleLogo.hidden = YES;
        self.attributionLabel.hidden = YES;
        return;
    }
#endif

    // We only relocate on iPhone, not on iPad
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        UIView * logo = self.googleLogo;
        // Use attribution label starting at iOS 6
        // This is the best I came up with : AFAIK, there's no way to tell
        // whether MKMapView is using Google Maps or Apple's.
        if(logo==nil && [[[UIDevice currentDevice] systemVersion] intValue]>=6)
            logo = self.attributionLabel;
        
        // compute margins only once
        static CGFloat xMargin = 0;
        if(xMargin==0) xMargin = MIN(logo.frame.origin.x, self.bounds.size.width-CGRectGetMaxX(logo.frame));
        static CGFloat yMargin = 0;
        if(yMargin==0){
            yMargin = MIN(logo.frame.origin.y, self.bounds.size.height-CGRectGetMaxY(logo.frame));
            yMargin += [[UIScreen mainScreen] applicationFrame].origin.y;
        }

        // top right corner
        logo.frame = (CGRect){CGPointMake(self.bounds.size.width - logo.frame.size.width - xMargin, yMargin),logo.frame.size};
        logo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
}

- (UIView*) googleLogo {
    // Up to iOS 5, and after on lower-end devices : the "Google" logo is an image
    UIImageView *imgView = nil;
    for (UIView *subview in self.subviews) {
        if ([subview isMemberOfClass:[UIImageView class]]) {
            imgView = (UIImageView*)subview;
            break;
        }
    }
    return imgView;
}

- (UIView*) attributionLabel {
    // Starting on iOS 6, with higher-end devices : the "Legal" text is a "MKAttributionLabel", subclass of UILabel.
    UILabel * label = nil;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            label = (UILabel*)subview;
            break;
        }
    }
    return label;
}

@end
