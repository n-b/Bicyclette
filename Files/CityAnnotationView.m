//
//  CityAnnotationView.m
//  Bicyclette
//
//  Created by Nicolas on 29/09/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "CityAnnotationView.h"
#import "Style.h"

@implementation CityAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self) {
        [self setupContents];
    }
    return self;
}

- (void) setupContents
{
    static CGImageRef s_image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id contents = self.layer.contents;
        if (CFGetTypeID((__bridge CFTypeRef)(contents))!=CGImageGetTypeID()) {
            return;
        }
        
        CIFilter * hueFilter = [CIFilter filterWithName:@"CIHueAdjust"];
        [hueFilter setValuesForKeysWithDictionary:
         @{kCIInputImageKey: [CIImage imageWithCGImage:(__bridge CGImageRef)(contents)],
           @"inputAngle": @(4.15)}]; // We're rotating from the red (3°) to kBicycletteBlue (215°), visually adjusted.
        
        CIImage * outputImage = [hueFilter outputImage];
        CGImageRef cgimg = [[CIContext contextWithOptions:nil] createCGImage:outputImage fromRect:[outputImage extent]];
        s_image = CGImageRetain(cgimg);
    });
    self.layer.contents = (__bridge id)(s_image);
}

@end
