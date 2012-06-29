//
//  UIColor+hsb.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 24/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (hsb)

- (id) initWithHSBString:(NSString*)hsbString;
- (NSString*) hsbString;

- (CGFloat) hue;
- (CGFloat) saturation;
- (CGFloat) brightness;
- (CGFloat) alpha;

@end
