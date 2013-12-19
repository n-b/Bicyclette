
//
//  MKMapView+AttributionLogo.m
//  Bicyclette
//
//  Created by Nicolas on 20/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "MKMapView+AttributionLogo.h"

@implementation MKMapView (AttributionLogo)

- (void) relocateAttributionLabelIfNecessary
{
#if SCREENSHOTS
    // Debug for screenshot (Default.png)
    {
        self.attributionLabel.hidden = YES;
        return;
    }
#endif

    // We only relocate on iPhone, not on iPad
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        UIView * label = self.attributionLabel;
        
        // compute margins only once
        static CGFloat xMargin = 0;
        if(xMargin==0) xMargin = MIN(label.frame.origin.x, self.bounds.size.width-CGRectGetMaxX(label.frame));
        static CGFloat yMargin = 0;
        if(yMargin==0){
            yMargin = MIN(label.frame.origin.y, self.bounds.size.height-CGRectGetMaxY(label.frame));
            yMargin += [[UIScreen mainScreen] applicationFrame].origin.y;
        }

        // top right corner
        [UIView performWithoutAnimation:^{
            label.frame = (CGRect){CGPointMake(self.bounds.size.width - label.frame.size.width - xMargin, yMargin),label.frame.size};
            label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        }];
    }
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
