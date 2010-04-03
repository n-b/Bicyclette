//
//  StationCell.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "StationCell.h"


@implementation StationCell
@synthesize station, stationInfo;

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
	if(self.selected)
		[[UIColor blueColor] set];
	else
		[[UIColor whiteColor] set];
	UIRectFill(rect);
	
	if(self.selected)
		[[UIColor whiteColor] set];
	else
		[[UIColor blackColor] set];

	NSString * name = [station objectForKey:@"name"];
	NSString * address = [station objectForKey:@"address"];
	[name drawAtPoint:CGPointMake(5, 5) withFont:bigFont];
	[address drawAtPoint:CGPointMake(5, 25) withFont:smallFont];
	
	if(stationInfo)
	{
		int available = [[stationInfo objectForKey:@"available"] intValue];
		int free = [[stationInfo objectForKey:@"free"] intValue];
		int total = [[stationInfo objectForKey:@"total"] intValue];
		int ticket = [[stationInfo objectForKey:@"ticket"] intValue];
		[[UIColor redColor] set];
		[[NSString stringWithFormat:@"A%d",available] drawAtPoint:CGPointMake(150, 5) withFont:bigFont];
		[[UIColor greenColor] set];
		[[NSString stringWithFormat:@"F%d",free] drawAtPoint:CGPointMake(200, 5) withFont:bigFont];
		[[UIColor grayColor] set];
		[[NSString stringWithFormat:@"(%d%s)",total,ticket?" +":""] drawAtPoint:CGPointMake(270, 5) withFont:smallFont];
	}
}

@end
