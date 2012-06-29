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
    CGFloat hue;
    if([self getHue:&hue saturation:NULL brightness:NULL alpha:NULL])
        return hue;
    return 0;
}
- (CGFloat) saturation
{
    CGFloat saturation;
    if([self getHue:NULL saturation:&saturation brightness:NULL alpha:NULL])
        return saturation;
    return 0;
}
- (CGFloat) brightness
{
    CGFloat brightness;
    if([self getHue:NULL saturation:NULL brightness:&brightness alpha:NULL])
        return brightness;
    return 0;
}
- (CGFloat) alpha
{
    CGFloat alpha;
    if([self getHue:NULL saturation:NULL brightness:NULL alpha:&alpha])
        return alpha;
    return 0;
}

@end
