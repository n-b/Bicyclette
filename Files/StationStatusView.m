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

- (void)dealloc
{
	self.station = nil;
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctxt = UIGraphicsGetCurrentContext();

	int availableSpots = self.station.status_availableValue;
	int freeSpots = self.station.status_freeValue;
	int totalSpots = self.displayOtherSpots ? self.station.status_totalValue : availableSpots+freeSpots;
	
	CGColorRef availableColor = [UIColor colorWithWhite:.1f alpha:1.f].CGColor;
	CGColorRef freeColor = [UIColor colorWithWhite:.5f alpha:1.f].CGColor;
	CGColorRef otherColor = [UIColor colorWithHue:0.02f saturation:1.f brightness:.56f alpha:1.f].CGColor;
	
    // Find the best row/columns repartition
    CGFloat ratio = rect.size.width/rect.size.height;
    int nbRows, nbCols;
    nbCols = lrintf(sqrtf(totalSpots*ratio));
    nbRows = lrintf(sqrtf(totalSpots/ratio));
    if( nbRows*nbCols < totalSpots )
        nbCols+=1;
    if( nbRows*nbCols < totalSpots )
        nbRows+=1;
    
    CGRect spotRect;
    spotRect.size.width = (rect.size.width-1)  / nbCols;
    spotRect.size.height = (rect.size.height-1)  / nbRows;
    
    CGContextSetFillColorWithColor(ctxt,availableColor);
    CGContextSetStrokeColorWithColor(ctxt,[UIColor whiteColor].CGColor);
    
    CGContextTranslateCTM(ctxt, 0, rect.size.height);
    CGContextScaleCTM(ctxt, 1, -1);

    CGRect intRect = CGRectZero;
    intRect.origin.x = 0.5;
    for (int col = 0; col<nbCols; col++) {
        intRect.origin.y = 0.5;
        for (int row = 0; row<nbRows && col*nbRows+row+1 <= totalSpots ; row++) {
            
            if(row+(col*nbRows)==availableSpots)
                CGContextSetFillColorWithColor(ctxt,freeColor);
            if(row+(col*nbRows)==availableSpots+freeSpots)
                CGContextSetFillColorWithColor(ctxt,otherColor);

            intRect.size.height = lroundf((row+1)*spotRect.size.height - intRect.origin.y);
            intRect.size.width = lroundf((col+1)*spotRect.size.width - intRect.origin.x);
            CGContextFillRect(ctxt, intRect);
            CGContextStrokeRect(ctxt, intRect);
            
            intRect.origin.y += intRect.size.height;
        }
        intRect.origin.x += intRect.size.width;
    }
}

@end
