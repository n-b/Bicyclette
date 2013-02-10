
//
//  Style.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "UIColor+hsb.h"

#define kBicycletteBlue					[UIColor colorWithHue:0.611 saturation:1.000 brightness:0.600 alpha:1.000]
#define kRegionAnnotationViewSize 		40

#define kStationAnnotationViewSize		30

#define kAnnotationFrame1Color			[UIColor colorWithWhite:.95 alpha:.7]
#define kAnnotationFrame2Color			[UIColor colorWithWhite:.1 alpha:1]
#define kAnnotationFrame3Color			[UIColor colorWithWhite:.7 alpha:1]


#define kRegionColor					[UIColor colorWithHue:0 saturation:.02 brightness:1 alpha:1]

#define kRegionFrame1Color				[UIColor colorWithWhite:.95 alpha:1]
#define kRegionFrame2Color				[UIColor colorWithHue:0.01 saturation:1 brightness:.84 alpha:1]
#define kRegionFrame3Color				[UIColor colorWithWhite:.95 alpha:1]

#define kGoodValueColor					[UIColor colorWithHue:0.356 saturation:0.850 brightness:0.750 alpha:1.000]
#define kWarningValueColor				[UIColor colorWithHue:0.056 saturation:0.880 brightness:0.850 alpha:1.000]
#define kCriticalValueColor				[UIColor colorWithHue:0.008 saturation:0.920 brightness:0.710 alpha:1.000]

#define kFenceBackgroundColor			[UIColor colorWithHue:0.714 saturation:0.753 brightness:0.536 alpha:0.500]

#define kAnnotationDash1Color			[UIColor colorWithHue:0.714 saturation:0.753 brightness:0.536 alpha:1.000]
#define kAnnotationDash2Color			[UIColor whiteColor]
#define kDashedBorderWidth				2
#define kDashLength						4

#define kUnknownValueColor				[UIColor colorWithHue:0 saturation:.02 brightness:.8 alpha:1]

#define kAnnotationTextColor			[UIColor colorWithHue:0 saturation:.02 brightness:1 alpha:1]

#define kAnnotationTitleTextColor		[kAnnotationTextColor colorWithBrightness:.07]
#define kAnnotationTitleShadowColor		[kAnnotationTextColor colorWithBrightness:1]
#define kAnnotationTitleFont			[UIFont fontWithName:@"AvenirNext-Bold" size:19]

#define kAnnotationDetailTextColor		[kAnnotationTextColor colorWithBrightness:.07]
#define kAnnotationDetailShadowColor	[kAnnotationTextColor colorWithBrightness:1]
#define kAnnotationDetailFont			[UIFont fontWithName:@"AvenirNext-Medium" size:16]

#define kAnnotationValueTextColor		[kAnnotationTextColor colorWithBrightness:.07]
#define kAnnotationValueTextColorAlt	[kAnnotationTextColor colorWithBrightness:.4]
#define kAnnotationValueShadowColor		[kAnnotationTextColor colorWithBrightness:1]
#define kAnnotationValueFont			[UIFont fontWithName:@"AvenirNext-Medium" size:18]
