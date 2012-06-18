//
//  TransparentToolbar.m
//  
//
//  Created by Nicolas Bouilleaud on 24/01/11.
//

#import "TransparentToolbar.h"


@implementation TransparentToolbar

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder: decoder];
	if(self!=nil) self.backgroundColor = [UIColor clearColor];
	return self;
}

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self!=nil) self.backgroundColor = [UIColor clearColor];
	return self;
}

- (void) drawRect:(CGRect) rect
{
}

@end
