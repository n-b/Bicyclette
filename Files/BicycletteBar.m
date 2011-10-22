//
//  BicycletteBar.m
//  Bicyclette
//
//  Created by Nicolas on 10/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteBar.h"
#import "NSArrayAdditions.h"
#import "UIImage+Tinting.h"


/****************************************************************************/
#pragma mark Support classes

@interface BicycletteBarArrow : UIView
@end

@interface BicycletteBarItem : UIBarButtonItem
@property (nonatomic) BOOL selected;
- (id)initWithImageName:(NSString *)imageName target:(id)target action:(SEL)action tag:(NSInteger)tag;
@end

/****************************************************************************/
#pragma mark Private Methods

@interface BicycletteBar ()
@property (nonatomic, strong) BicycletteBarArrow * arrow;
@property (weak, nonatomic, readonly) NSArray* buttons;
- (void) selectButton:(id)sender;
@end

/****************************************************************************/
#pragma mark -

@implementation BicycletteBar
@synthesize selectedIndex, delegate, arrow;

- (void) awakeFromNib
{
	[super awakeFromNib];
	
	selectedIndex = NSNotFound;
	
	UIBarButtonItem * item = nil;
	NSMutableArray * items = [NSMutableArray array];
	[items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL]];

	item = [[BicycletteBarItem alloc] initWithImageName:@"RegionsTab.png" target:self action:@selector(selectButton:) tag:0];
	item.enabled = YES;
	[items addObject:item];

	item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
	item.width = 21;
	[items addObject:item];

	item = [[BicycletteBarItem alloc] initWithImageName:@"FavoritesTab.png" target:self action:@selector(selectButton:) tag:1];
	[items addObject:item];

	item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
	item.width = 21;
	[items addObject:item];

	item = [[BicycletteBarItem alloc] initWithImageName:@"MapTab.png" target:self action:@selector(selectButton:) tag:2];
	[items addObject:item];
	
	[items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL]];
	self.items = items;
	
	CGFloat arrowWidth = self.bounds.size.width + ([[self.buttons lastObject] customView].center.x - [[self.buttons objectAtIndex:0] customView].center.x);

	self.arrow = [[BicycletteBarArrow alloc] initWithFrame:CGRectMake(0, 0, arrowWidth, 0)];
	[self addSubview:arrow];
	self.clipsToBounds = NO;
}


/****************************************************************************/
#pragma mark -

- (void)drawRect:(CGRect)rect {
	// remove two first lines
	CGContextRef ctx = UIGraphicsGetCurrentContext();	
	CGContextSaveGState(ctx);
	CGRect area = rect;
    area.origin.y+=2;
	area.size.height-=2;
    CGContextClipToRect(ctx, area);
	[super drawRect:rect];
	CGContextRestoreGState(ctx);
}


- (NSArray*) buttons
{
	return [self.items filteredArrayWithValue:[BicycletteBarItem class] forKey:@"class"];
}

- (void) setSelectedIndex:(NSUInteger)value
{
	if(selectedIndex!=value)
	{
		selectedIndex = value;
		[self.buttons setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
		[[self.buttons objectAtIndex:value] setSelected:YES];
		
		[UIView beginAnimations:nil context:NULL];
		CGPoint arrowCenter = self.arrow.center;
		arrowCenter.x = [[self.buttons objectAtIndex:value] customView].center.x;
		self.arrow.center = arrowCenter;
		[UIView commitAnimations];
	}
}

- (void) selectButton:(id)sender
{
	self.selectedIndex = [sender tag];
	[self.delegate bicycletteBar:self didSelectIndex:self.selectedIndex];
}

@end

/****************************************************************************/
#pragma mark -

@implementation BicycletteBarArrow

- (id) initWithFrame:(CGRect)frame
{
	frame.origin.y = - 5;
	frame.size.height = 7;
	self = [super initWithFrame:frame];
	if (self != nil) {
		self.backgroundColor = [UIColor clearColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.tag = NSNotFound;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();	
	CGFloat xCenter = rect.size.width/2 + .5;
	
	CGPoint line [] = {{0,6.5}, {xCenter-5,6.5},
		{xCenter-5,6.5}, {xCenter,1.5},
		{xCenter,1.5}, {xCenter+5,6.5},
		{xCenter+5,6.5}, {rect.size.width,6.5}};
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, line[2].x, line[2].y);
	CGPathAddLineToPoint(path, NULL, line[4].x, line[4].y);
	CGPathAddLineToPoint(path, NULL, line[6].x, line[6].y);
	CGPathAddLineToPoint(path, NULL, line[2].x, line[2].y);
	CGContextAddPath(ctx, path);
	CGPathRelease(path);
	
    UIColor * gray = [UIColor colorWithWhite:.5 alpha:.7];
	UIColor * black = [UIColor colorWithWhite:.1 alpha:.9];
	
	CGContextSetFillColorWithColor(ctx, gray.CGColor);
	CGContextSetStrokeColorWithColor(ctx, gray.CGColor);
	CGContextDrawPath(ctx, kCGPathFillStroke);
	
	CGContextSetStrokeColorWithColor(ctx, gray.CGColor);
	CGContextStrokeLineSegments(ctx, line, sizeof(line)/sizeof(CGPoint));
	
	CGContextSetStrokeColorWithColor(ctx, black.CGColor);
	for (unsigned int i = 0; i < sizeof(line)/sizeof(CGPoint); i++) line[i].y -= 1;
	CGContextStrokeLineSegments(ctx, line, sizeof(line)/sizeof(CGPoint));
}

@end

/****************************************************************************/
#pragma mark -

@implementation BicycletteBarItem

@synthesize selected;

- (id)initWithImageName:(NSString *)aImageName target:(id)target action:(SEL)action tag:(NSInteger)tag
{
	UIImage * imgSelected = [UIImage imageNamed:aImageName];
	UIImage * imgNotSelected = [imgSelected tintedImageWithColor:[UIColor colorWithWhite:0.1 alpha:1]];
	UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.showsTouchWhenHighlighted = YES;
	button.adjustsImageWhenHighlighted = NO;
	[button setImage:imgSelected forState:UIControlStateSelected];
	[button setImage:imgSelected forState:UIControlStateHighlighted];
	[button setImage:imgNotSelected forState:UIControlStateNormal];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	button.tag = tag;
	button.frame = CGRectMake(0, 0, 44, 30);
	
	return [super initWithCustomView:button];
}

- (void) setSelected:(BOOL)value
{
	selected = value;
	[(UIButton*)self.customView setSelected:self.selected];
}

@end
