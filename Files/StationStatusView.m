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

	CGFloat bubbleWidth = rect.size.width/self.station.status_totalValue;
	CGFloat bubbleHeight = rect.size.height;
	
	CGContextSetFillColorWithColor(ctxt, [UIColor blackColor].CGColor);
	for (int i = 0; i < self.station.status_availableValue; i++) {
		CGContextFillRect(ctxt, CGRectMake(bubbleWidth*i + 1, 1, bubbleWidth-2, bubbleHeight-2));
	}

	CGContextSetFillColorWithColor(ctxt, [UIColor grayColor].CGColor);
	for (int i = self.station.status_availableValue; i < self.station.status_availableValue+self.station.status_freeValue; i++) {
		CGContextFillRect(ctxt, CGRectMake(bubbleWidth*i + 1, 1, bubbleWidth-2, bubbleHeight-2));
	}
	
	CGContextSetFillColorWithColor(ctxt, [UIColor colorWithWhite:.8 alpha:1].CGColor);
	for (int i = self.station.status_availableValue+self.station.status_freeValue; i < self.station.status_totalValue; i++) {
		CGContextFillRect(ctxt, CGRectMake(bubbleWidth*i + 1, 1, bubbleWidth-2, bubbleHeight-2));
	}
	
	
	CGContextSetFillColorWithColor(ctxt, [UIColor colorWithWhite:1 alpha:1].CGColor);
	CGContextSetShadowWithColor(ctxt, CGSizeMake(0,0), 2, [UIColor colorWithWhite:0 alpha:1].CGColor);
	[self.station.statusDateDescription drawInRect:rect
										  withFont:[UIFont boldSystemFontOfSize:16] 
									 lineBreakMode:UILineBreakModeClip
										 alignment:UITextAlignmentCenter];
}

@end
