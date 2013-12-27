//
//  BICCGUtilities.m
//  Bicyclette
//
//  Created by Nicolas on 07/10/2013.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "BICCGUtilities.h"

// Create a path for a rect with rounded corners
CGPathRef BIC_CGPathCreateWithRoundedRect(CGRect rect, CGFloat cornerRadius)
{
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, minx, midy);
    
    CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, cornerRadius);
    CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, cornerRadius);
    
    CGPathCloseSubpath(path);
    
    return path;
}
