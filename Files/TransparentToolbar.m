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
    self.backgroundColor = [UIColor clearColor];
	return self;
}

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
	return self;
}

- (void) drawRect:(CGRect) rect
{
    // we take "translucent" for "transparent"
    if(!self.translucent)
        [super drawRect:rect];
}

@end
