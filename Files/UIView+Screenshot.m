//
//  UIView+Screenshot.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 10/05/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "UIView+Screenshot.h"

@implementation UIView (ImageRepresentation)

- (UIImage *)screenshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end
