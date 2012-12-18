//
//  UIViewController+Banner.m
//  Bicyclette
//
//  Created by Nicolas on 18/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "UIViewController+Banner.h"

const NSUInteger kBannerViewID = 42106;


@implementation UIViewController (Banner)

- (UILabel*)banner {
    return (UILabel*) [self.view viewWithTag:kBannerViewID];
}

- (void) createBannerLabel
{
    if(self.banner==nil)
    {
        CGRect f = self.view.bounds;
        f.size.height = (int)(f.size.height/6);
        UIView * frame = [[UIView alloc] initWithFrame:f];
        frame.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        
        f.size.height -= 20;
        f.origin.y += 20;
        UILabel * banner = [[UILabel alloc] initWithFrame:f];
        banner.tag = kBannerViewID;
        
        banner.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        banner.backgroundColor = [UIColor colorWithHue:.65 saturation:.5 brightness:.7 alpha:.5];
        banner.font = [UIFont systemFontOfSize:28];
        banner.textAlignment = UITextAlignmentCenter;
        banner.textColor = [UIColor colorWithWhite:1 alpha:.8];
        banner.shadowColor = [UIColor colorWithWhite:.67 alpha:1];

        [frame addSubview:banner];
        [self.view addSubview:frame];
    }
}

- (void) displayBanner:(NSString*)message
{
    [self createBannerLabel];
    self.banner.text = message;
    self.banner.alpha = 1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissBanner) object:nil];
    [self performSelector:@selector(dismissBanner) withObject:nil afterDelay:3];
}

- (void) dismissBanner
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [UIView animateWithDuration:.2 animations:^{
        self.banner.alpha = 0;
    }];
}

@end
