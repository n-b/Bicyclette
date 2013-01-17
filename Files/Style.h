
//
//  Style.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "UIColor+hsb.h"

#define kRegionAnnotationViewSize 		40

#define kStationAnnotationViewSize		30

#define kAnnotationFrame1Color			[UIColor colorWithWhite:.95 alpha:.7]
#define kAnnotationFrame2Color			[UIColor colorWithWhite:.1 alpha:1]
#define kAnnotationFrame3Color			[UIColor colorWithWhite:.7 alpha:1]

#define kAnnotationDash1Color			[UIColor colorWithWhite:.95 alpha:1]
#define kAnnotationDash2Color			[UIColor colorWithWhite:.1 alpha:1]

#define kRegionColor					[UIColor colorWithHue:0 saturation:.02 brightness:1 alpha:1]

#define kRegionFrame1Color				[UIColor colorWithWhite:.95 alpha:1]
#define kRegionFrame2Color				[UIColor colorWithHue:0.01 saturation:1 brightness:.84 alpha:1]
#define kRegionFrame3Color				[UIColor colorWithWhite:.95 alpha:1]

#define kGoodValueColor					[UIColor colorWithHue:0.356 saturation:0.853 brightness:0.745 alpha:1.000]
#define kWarningValueColor				[UIColor colorWithHue:0.058 saturation:0.885 brightness:0.851 alpha:1.000]
#define kCriticalValueColor				[UIColor colorWithHue:0.008 saturation:0.917 brightness:0.710 alpha:1.000]

#define kUnknownValueColor				[UIColor colorWithHue:0 saturation:.02 brightness:.8 alpha:1]

#define kAnnotationTextColor			[UIColor colorWithHue:0 saturation:.02 brightness:1 alpha:1]

#define kAnnotationTitleTextColor		[kAnnotationTextColor colorWithBrightness:.07]
#define kAnnotationTitleShadowColor		[kAnnotationTextColor colorWithBrightness:1]
#define kAnnotationTitleFont			[UIFont fontWithName:@"GillSans-Bold" size:19]

#define kAnnotationDetailTextColor		[kAnnotationTextColor colorWithBrightness:.07]
#define kAnnotationDetailShadowColor	[kAnnotationTextColor colorWithBrightness:1]
#define kAnnotationDetailFont			[UIFont fontWithName:@"GillSans" size:16]

#define kAnnotationValueTextColor		[kAnnotationTextColor colorWithBrightness:.07]
#define kAnnotationValueShadowColor		[kAnnotationTextColor colorWithBrightness:1]
#define kAnnotationValueFont			[UIFont fontWithName:@"AvenirNext-Medium" size:18]

#define kRadarAnnotationHandleSize		20
#define kRadarAnnotationDefaultColor	[UIColor colorWithHue:0 saturation:0 brightness:1 alpha:1]
#define kRadarAnnotationSelectedColor	[UIColor colorWithHue:0 saturation:0 brightness:.9 alpha:1]
