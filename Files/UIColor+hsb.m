//
//  UIColor+hsb.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 24/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "UIColor+hsb.h"

@implementation UIColor (Components)

- (id) initWithHSBString:(NSString*)hsbString
{
    NSArray * components = [hsbString componentsSeparatedByString:@","];
    return [self initWithHue:[components[0] floatValue]
                  saturation:[components[1] floatValue]
                  brightness:[components[2] floatValue]
                       alpha:[components[3] floatValue]];
}

- (NSString*) hsbString
{
    return [NSString stringWithFormat:@"%f,%f,%f,%f",
            self.hue,
            self.saturation,
            self.brightness,
            self.alpha];
}

- (CGFloat) hue
{
    CGFloat h;
    if([self getHue:&h saturation:NULL brightness:NULL alpha:NULL])
        return h;
    return 0;
}
- (CGFloat) saturation
{
    CGFloat s;
    if([self getHue:NULL saturation:&s brightness:NULL alpha:NULL])
        return s;
    return 0;
}
- (CGFloat) brightness
{
    CGFloat b;
    if([self getHue:NULL saturation:NULL brightness:&b alpha:NULL])
        return b;
    return 0;
}
- (CGFloat) alpha
{
    CGFloat a;
    if([self getHue:NULL saturation:NULL brightness:NULL alpha:&a])
        return a;
    return 0;
}

- (UIColor*) colorWithHue:(CGFloat)h_
{
    CGFloat s, b, a;
    if([self getHue:NULL saturation:&s brightness:&b alpha:&a])
        return [[self class] colorWithHue:h_ saturation:s brightness:b alpha:a];
    return nil;
}
- (UIColor*) colorWithSaturation:(CGFloat)s_
{
    CGFloat h, b, a;
    if([self getHue:&h saturation:NULL brightness:&b alpha:&a])
        return [[self class] colorWithHue:h saturation:s_ brightness:b alpha:a];
    return nil;
}
- (UIColor*) colorWithBrightness:(CGFloat)b_
{
    CGFloat h, s, a;
    if([self getHue:&h saturation:&s brightness:NULL alpha:&a])
        return [[self class] colorWithHue:h saturation:s brightness:b_ alpha:a];
    return nil;
}
- (UIColor*) colorWithAlpha:(CGFloat)a_
{
    CGFloat h, s, b;
    if([self getHue:&h saturation:&s brightness:&b alpha:NULL])
        return [[self class] colorWithHue:h saturation:s brightness:b alpha:a_];
    return nil;
}

- (UIColor*) colorByAddingHue:(CGFloat)h_
{
    CGFloat h, s, b, a;
    if([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [[self class] colorWithHue:h+h_ saturation:s brightness:b alpha:a];
    return nil;
}
- (UIColor*) colorByAddingSaturation:(CGFloat)s_
{
    CGFloat h, s, b, a;
    if([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [[self class] colorWithHue:h saturation:s+s_ brightness:b alpha:a];
    return nil;
}
- (UIColor*) colorByAddingBrightness:(CGFloat)b_
{
    CGFloat h, s, b, a;
    if([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [[self class] colorWithHue:h saturation:s brightness:b+b_ alpha:a];
    return nil;
}
- (UIColor*) colorByAddingAlpha:(CGFloat)a_
{
    CGFloat h, s, b, a;
    if([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [[self class] colorWithHue:h saturation:s brightness:b alpha:a+a_];
    return nil;
}

@end
