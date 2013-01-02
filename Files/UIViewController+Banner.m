//
//  UIViewController+Banner.m
//  Bicyclette
//
//  Created by Nicolas on 18/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "UIViewController+Banner.h"

const NSUInteger kBannerViewTag = 42106;
const NSUInteger kBannerSuperviewViewTag = 42105;


@implementation UIViewController (Banner)

- (UILabel*)banner {
    return (UILabel*) [self.view viewWithTag:kBannerViewTag];
}

- (UILabel*)bannerSuperview {
    return (UILabel*) [self.view viewWithTag:kBannerSuperviewViewTag];
}

- (void) createBannerLabel
{
    if(self.banner==nil)
    {
        CGRect f = self.view.bounds;
        f.size.height = (int)(f.size.height/6);
        UIView * frame = [[UIView alloc] initWithFrame:f];
        frame.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        frame.tag = kBannerSuperviewViewTag;
        
        f.size.height -= 20;
        f.origin.y += 20;
        UILabel * banner = [[UILabel alloc] initWithFrame:f];
        banner.tag = kBannerViewTag;
        
        banner.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        banner.backgroundColor = [UIColor colorWithHue:.65 saturation:.5 brightness:.7 alpha:.5];
        banner.font = [UIFont systemFontOfSize:20];
        banner.numberOfLines = 0;
        banner.textAlignment = NSTextAlignmentCenter;
        banner.textColor = [UIColor colorWithWhite:1 alpha:.8];
        banner.shadowColor = [UIColor colorWithWhite:.67 alpha:1];

        [frame addSubview:banner];
        [self.view addSubview:frame];
    }
}

- (void) displayBanner:(NSString*)message sticky:(BOOL)sticky
{
    [self createBannerLabel];
    self.banner.text = message;
    self.bannerSuperview.alpha = 1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissBanner) object:nil];

    if(!sticky)
        [self performSelector:@selector(dismissBanner) withObject:nil afterDelay:3];
}

- (void) dismissBanner
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [UIView animateWithDuration:.2 animations:^{
        self.bannerSuperview.alpha = 0;
    }];
}

@end
