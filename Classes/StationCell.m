//
//  StationCell.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "StationCell.h"


@implementation StationCell
@synthesize station, stationInfo, isFavorite;

static UIFont * bigFont = nil;
static UIFont * smallFont = nil;

+ (id) reusableCellForTable:(UITableView*)table
{
	if(bigFont==nil)
	{
		bigFont = [[UIFont boldSystemFontOfSize:[UIFont buttonFontSize]] retain];
		smallFont = [[UIFont systemFontOfSize:[UIFont systemFontSize]] retain];
	}
	
	NSString * reuseID = NSStringFromClass([self class]);
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID] autorelease];
    }
	return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    }
    return self;
}

- (void)dealloc {
	self.station = nil;
    [super dealloc];
}

- (void)prepareForReuse
{
	[self setNeedsDisplay];
}

- (void) drawContentView:(CGRect)rect
{
	if(self.selected || self.isFavorite)
		[[UIColor lightGrayColor] set];
	else
		[[UIColor whiteColor] set];
	UIRectFill(rect);
	
	UIColor * textColor;
	if(self.selected || self.isFavorite)
		textColor = [UIColor whiteColor];
	else
		textColor = [UIColor blackColor];

	[textColor set];
	NSString * name = [station objectForKey:@"name"];
	NSString * address = [station objectForKey:@"address"];
	[name drawAtPoint:CGPointMake(5, 5) withFont:bigFont];
	[address drawAtPoint:CGPointMake(5, 25) withFont:smallFont];
	
	if(stationInfo)
	{
		//total
		[textColor set];
		int total = [[stationInfo objectForKey:@"total"] intValue];
		int ticket = [[stationInfo objectForKey:@"ticket"] intValue];
		[[NSString stringWithFormat:@"(%d%s)",total,ticket?" +":""] drawAtPoint:CGPointMake(5, 40) withFont:smallFont];

		// parking
		int free = [[stationInfo objectForKey:@"free"] intValue];
		BOOL wantsParking = [[NSUserDefaults standardUserDefaults] boolForKey:@"ParkingWanted"];
		if(wantsParking)
		{
			if(free==0)
				[[UIColor redColor] set];
			else if(free<5)
				[[UIColor orangeColor] set];
			else
				[[UIColor greenColor] set];
		}
		else
			[textColor set];
		[[NSString stringWithFormat:@"%d places",free] drawAtPoint:CGPointMake(200, 5) withFont:bigFont];
	
		// bikes
		int available = [[stationInfo objectForKey:@"available"] intValue];
		if(!wantsParking)
		{
			if(available==0)
				[[UIColor redColor] set];
			else if(available<5)
				[[UIColor orangeColor] set];
			else
				[[UIColor greenColor] set];
		}
		else
			[textColor set];
		[[NSString stringWithFormat:@"%d vélos",available] drawAtPoint:CGPointMake(110, 5) withFont:bigFont];
	}
}

@end
