//
//  UIImage+Tinting.m
//  Bicyclette
//
//  Created by Nicolas on 11/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "UIImage+Tinting.h"


@implementation UIImage(Tinting)

- (UIImage *)tintedImageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContext(self.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = {CGPointZero, self.size};
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, self.CGImage);
    
    [color set];
    CGContextFillRect(ctx, area);
	
    CGContextRestoreGState(ctx);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextDrawImage(ctx, area, self.CGImage);
	
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
