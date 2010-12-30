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
@synthesize displayOtherSpots;
@synthesize displayLegend;

- (void)dealloc
{
	self.station = nil;
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctxt = UIGraphicsGetCurrentContext();

	int available = self.station.status_availableValue;
	int free = self.station.status_freeValue;
	int total = self.station.status_totalValue;
	int other = total-available-free;
	
	CGColorRef availableColor = [UIColor blackColor].CGColor;
	CGColorRef freeColor = [UIColor colorWithWhite:.6f alpha:1.f].CGColor;
	CGColorRef otherColor = [UIColor colorWithHue:0.02f saturation:1.f brightness:.56f alpha:1.f].CGColor;
	
	// -
	int totalSpot = self.displayOtherSpots?total:available+free;
	
	CGPoint circleCenter = {CGRectGetMidX(rect), CGRectGetMidY(rect)};
	CGFloat circlerOuterSize = rect.size.height/2.f;
	CGFloat circleInnerSize = rect.size.height/3.1f;
	
	CGFloat spotAngle = 2.f * (float)M_PI / totalSpot;
	CGFloat zeroAngle = -M_PI;
	
	CGContextSetFillColorWithColor(ctxt,availableColor);
	for (int i = 0; i < totalSpot; i++) {
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
		
		if(i==available)
			CGContextSetFillColorWithColor(ctxt,freeColor);
		if(i==available+free)
			CGContextSetFillColorWithColor(ctxt,otherColor);
		CGContextFillPath(ctxt);
	}
	
	
	// -
	if( self.station.status_date && !self.station.loading)
	{
		CGFloat fontSize = self.displayLegend?circlerOuterSize/4.1f:circlerOuterSize/2.5f;
		UIFont * font = [UIFont boldSystemFontOfSize:fontSize];
		UIFont * smallFont = [font fontWithSize:fontSize/1.5f];
		CGFloat textMargin = -circlerOuterSize/15.0f;
		
		NSString * availableString;
		NSString * freeString;
		NSString * otherString;

		if(self.displayLegend)
		{
			availableString = available<=1
				?[NSString stringWithFormat:NSLocalizedString(@"%d vélo",@""),available]
				:[NSString stringWithFormat:NSLocalizedString(@"%d vélos",@""),available];
			freeString = free<=1
			?[NSString stringWithFormat:NSLocalizedString(@"%d place",@""),free]
			:[NSString stringWithFormat:NSLocalizedString(@"%d places",@""),free];
			otherString = other<=1
			?[NSString stringWithFormat:NSLocalizedString(@"%d indisponible",@""),other]
			:[NSString stringWithFormat:NSLocalizedString(@"%d indisponibles",@""),other];
		}
		else
		{
			availableString = [NSString stringWithFormat:@"%d",available];
			freeString = [NSString stringWithFormat:@"%d",free];
			otherString = [NSString stringWithFormat:@"%d",other];
		}
		
		CGSize availableStringSize = [availableString sizeWithFont:font];
		CGSize freeStringSize = [freeString sizeWithFont:font];
		CGSize otherStringSize = [otherString sizeWithFont:smallFont];

		CGFloat yPos = circleCenter.y;
		yPos -= availableStringSize.height + textMargin;
		if(self.displayOtherSpots && other)
			yPos -= otherStringSize.height/2.0f;

		CGContextSetFillColorWithColor(ctxt,availableColor);
		CGRect availableStringRect = CGRectMake(circleCenter.x-availableStringSize.width/2, yPos, availableStringSize.width, availableStringSize.height);
		[availableString drawInRect:availableStringRect withFont:font];
		yPos += availableStringSize.height + textMargin;

		if(self.displayOtherSpots && other)
		{
			CGContextSetFillColorWithColor(ctxt,otherColor);
			CGRect otherStringRect = CGRectMake(circleCenter.x-otherStringSize.width/2, yPos, otherStringSize.width, otherStringSize.height);
			[otherString drawInRect:otherStringRect withFont:smallFont];	
			yPos += otherStringSize.height + textMargin;
		}
		
		CGContextSetFillColorWithColor(ctxt,freeColor);
		CGRect freeStringRect = CGRectMake(circleCenter.x-freeStringSize.width/2, yPos, freeStringSize.width, freeStringSize.height);
		[freeString drawInRect:freeStringRect withFont:font];	
	}
}

@end
