//
//  UIApplication+screenshot.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 28/09/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//
// http://developer.apple.com/library/ios/#qa/qa1703/_index.html

#if SCREENSHOTS

#import "UIApplication+screenshot.h"

@implementation UIApplication (screenshot)

- (UIImage*)screenshot
{
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContextWithOptions(keyWindow.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [keyWindow drawViewHierarchyInRect:keyWindow.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end

#endif
