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

@interface BicycletteBar ()
- (void) selectButton:(id)sender;
@end

@interface BicycletteBarItem : UIBarButtonItem
@property (nonatomic) BOOL selected;
- (id)initWithImageName:(NSString *)imageName target:(id)target action:(SEL)action tag:(NSInteger)tag;
@end


@implementation BicycletteBar
@synthesize selectedIndex, delegate;

- (void) awakeFromNib
{
	[super awakeFromNib];
	
	selectedIndex = NSNotFound;
	
	UIBarButtonItem * item = nil;
	NSMutableArray * items = [NSMutableArray array];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease]];

	item = [[[BicycletteBarItem alloc] initWithImageName:@"RegionsTab.png" target:self action:@selector(selectButton:) tag:0] autorelease];
	item.enabled = YES;
	[items addObject:item];

	item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL] autorelease];
	item.width = 21;
	[items addObject:item];

	item = [[[BicycletteBarItem alloc] initWithImageName:@"FavoritesTab.png" target:self action:@selector(selectButton:) tag:1] autorelease];
	[items addObject:item];

	item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL] autorelease];
	item.width = 21;
	[items addObject:item];

	item = [[[BicycletteBarItem alloc] initWithImageName:@"MapTab.png" target:self action:@selector(selectButton:) tag:2] autorelease];
	[items addObject:item];
	
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease]];
	self.items = items;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
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
		[self.delegate bicycletteBar:self didSelectIndex:self.selectedIndex];
	}
}


- (void) selectButton:(id)sender
{
	self.selectedIndex = [sender tag];
}

@end



@implementation BicycletteBarItem

@synthesize selected;

- (id)initWithImageName:(NSString *)aImageName target:(id)target action:(SEL)action tag:(NSInteger)tag
{
	UIImage * imgSelected = [UIImage imageNamed:aImageName];
	UIImage * imgNotSelected = [imgSelected tintedImageWithColor:[UIColor grayColor]];
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
