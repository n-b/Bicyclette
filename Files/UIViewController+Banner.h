//
//  UIViewController+Banner.h
//  Bicyclette
//
//  Created by Nicolas on 18/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@interface UIViewController (Banner)
extern const NSUInteger kBannerViewID;
- (void) displayBannerTitle:(NSString*)title subtitle:(NSString*)subtitle sticky:(BOOL)sticky;
- (void) dismissBanner;
@end
