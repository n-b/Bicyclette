//
//  UIViewController+Banner.m
//  Bicyclette
//
//  Created by Nicolas on 18/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "UIViewController+Banner.h"
#import "Style.h"
#import "UIView+NibLoading.h"

@interface BannerView : NibLoadedView
@property IBOutlet UILabel * bigTitleLabel;
@property IBOutlet UILabel * smallTitleLabel;
@property IBOutlet UILabel * subtitleLabel;
@end

@implementation BannerView
@end

const NSUInteger kBannerViewTag = 42105;

@implementation UIViewController (Banner)

- (BannerView*)bannerView {
    BannerView * banner = (BannerView*)[self.view viewWithTag:kBannerViewTag];
    if(banner==nil)
    {
        CGRect f = self.view.bounds;
        f.size.height = 44;
        f = CGRectOffset(f, 0, 20);
        banner = [[BannerView alloc] initWithFrame:f];
        banner.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        banner.tag = kBannerViewTag;
        [self.view addSubview:banner];
    }
    return banner;
}

- (void) displayBannerTitle:(NSString*)title subtitle:(NSString*)subtitle sticky:(BOOL)sticky
{
    if([subtitle length]){
        self.bannerView.bigTitleLabel.text = nil;
        self.bannerView.smallTitleLabel.text = title;
        self.bannerView.subtitleLabel.text = subtitle;
    } else {
        self.bannerView.bigTitleLabel.text = title;
        self.bannerView.smallTitleLabel.text = nil;
        self.bannerView.subtitleLabel.text = nil;
    }

    self.bannerView.alpha = 1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissBanner) object:nil];

    if(!sticky)
        [self performSelector:@selector(dismissBanner) withObject:nil afterDelay:3];
}

- (void) dismissBanner
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [UIView animateWithDuration:.2 animations:^{
        self.bannerView.alpha = 0;
    }];
}

@end
