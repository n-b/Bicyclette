//
//  UIBarButtonItem+BICMargins.m
//  Bicyclette
//
//  Created by Nicolas on 05/12/2013.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "UIBarButtonItem+BICMargins.h"

@implementation UIBarButtonItem (BICMargins)
+ (instancetype) bic_negativeMarginButtonItem
{
    UIBarButtonItem * item = [[self alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item.width = -8;
    return item;
}
+ (instancetype) bic_flexibleMarginButtonItem
{
    return [[self alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}
@end
