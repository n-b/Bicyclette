
//
//  Style.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "UIColor+hsb.h"

#define kBicycletteBlue					[UIColor colorWithHue:0.591 saturation:0.916 brightness:0.984 alpha:1.000]

#define kStationAnnotationViewSize		30

#define kAnnotationFrame1Color			[UIColor colorWithWhite:.95 alpha:1]


#define kRegionFrame1Color				[UIColor colorWithWhite:.95 alpha:1]
#define kRegionFrame2Color				[UIColor colorWithHue:0.01 saturation:1 brightness:.84 alpha:1]

#define kGoodValueColor					[UIColor colorWithRed:25/255.0f green:188/255.0f blue:63/255.0f alpha:1.0]
#define kWarningValueColor				[UIColor colorWithRed:221/255.0f green:170/255.0f blue:59/255.0f alpha:1.0]
#define kCriticalValueColor				[UIColor colorWithRed:229/255.0f green:0/255.0f blue:15/255.0f alpha:1.0]
#define kUnknownValueColor				[UIColor colorWithHue:0 saturation:.02 brightness:.8 alpha:1]

#define kFenceBackgroundColor			[kBicycletteBlue colorWithAlpha:.2]

#define kAnnotationValueFont			[UIFont fontWithName:@"AvenirNext-Medium" size:18]
