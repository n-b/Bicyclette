//
//  StationStatusView.m
//  Bicyclette
//
//  Created by Nicolas on 14/11/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "StationStatusView.h"
#import "Station.h"

@implementation StationStatusView
@synthesize station;

- (void)dealloc
{
	self.station = nil;
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctxt = UIGraphicsGetCurrentContext();

	CGColorRef availableColor = [UIColor blackColor].CGColor;
	CGColorRef freeColor = [UIColor grayColor].CGColor;
	CGColorRef otherColor = [UIColor colorWithWhite:.8f alpha:1].CGColor;
	
	// -
	CGPoint circleCenter = {CGRectGetMidX(rect), CGRectGetMidY(rect)};
	CGFloat circlerOuterSize = rect.size.height/2.f;
	CGFloat circleInnerSize = rect.size.height/3.1f;
	
	CGFloat spotAngle = 2.f * (float)M_PI / self.station.status_totalValue;
	CGFloat zeroAngle = -M_PI;
	
	CGContextSetFillColorWithColor(ctxt,availableColor);
	for (int i = 0; i < self.station.status_totalValue; i++) {
		CGFloat angleStart = zeroAngle + (i+0.1f) * spotAngle;
		CGFloat angleEnd = zeroAngle + (i+0.9f) * spotAngle;
		CGPoint points [4];
		points[0] = (CGPoint){circleCenter.x + circleInnerSize * cosf(angleStart), circleCenter.y + circleInnerSize * sinf(angleStart)};
		points[1] = (CGPoint){circleCenter.x + circlerOuterSize * cosf(angleStart), circleCenter.y + circlerOuterSize * sinf(angleStart)};
		points[2] = (CGPoint){circleCenter.x + circlerOuterSize * cosf(angleEnd), circleCenter.y + circlerOuterSize * sinf(angleEnd)};
		points[3] = (CGPoint){circleCenter.x + circleInnerSize * cosf(angleEnd), circleCenter.y + circleInnerSize * sinf(angleEnd)};
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddLines(path, NULL, points, sizeof(points)/sizeof(CGPoint));
		CGContextAddPath(ctxt, path);
		CGPathRelease(path);
		
		if(i==self.station.status_availableValue)
			CGContextSetFillColorWithColor(ctxt,freeColor);
		if(i==self.station.status_availableValue+self.station.status_freeValue)
			CGContextSetFillColorWithColor(ctxt,otherColor);
		CGContextFillPath(ctxt);
	}
	
	
	// -
	if( self.station.status_date && !self.station.loading)
	{
		UIFont * font = [UIFont boldSystemFontOfSize:18];
		CGFloat textMargin = -1.f;
		//	NSString * totalString = [NSString stringWithFormat:@"%d",self.station.status_totalValue];
		
		NSString * availableString = [NSString stringWithFormat:@"%d",self.station.status_availableValue];
		NSString * freeString = [NSString stringWithFormat:@"%d",self.station.status_freeValue];
		
		CGContextSetFillColorWithColor(ctxt,availableColor);
		CGSize availableStringSize = [availableString sizeWithFont:font];
		CGRect availableStringRect = CGRectMake(circleCenter.x-availableStringSize.width/2, circleCenter.y-availableStringSize.height-textMargin, availableStringSize.width, availableStringSize.height);
		[availableString drawInRect:availableStringRect withFont:font];
		
		CGContextSetFillColorWithColor(ctxt,freeColor);
		CGSize freeStringSize = [freeString sizeWithFont:font];
		CGRect freeStringRect = CGRectMake(circleCenter.x-freeStringSize.width/2, circleCenter.y+textMargin, freeStringSize.width, freeStringSize.height);
		[freeString drawInRect:freeStringRect withFont:font];	
	}
}

@end
