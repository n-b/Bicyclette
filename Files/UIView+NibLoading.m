//
//  UIView+NibLoading.m
//  
//
//  Created by Nicolas Bouilleaud on 09/03/11.
//
//

#import "UIView+NibLoading.h"

@implementation UIView(NibLoading)

- (void) loadContentsFromNib
{
	[self loadContentsFromNibNamed:NSStringFromClass([self class])];
}

- (void) loadContentsFromNibNamed:(NSString*)nibName
{
	NSArray * views = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
	NSAssert1(views!=nil, @"Can't load nib named %@",nibName);
	NSAssert1(views.count==1, @"There must be exactly one root container view in %@.",nibName);
	UIView * containerView = [views objectAtIndex:0];
	NSAssert2([[containerView class] isEqual:[UIView class]], @"The container view in nib %@ should be a UIView instead of %@. (It's discarded anyway).",nibName,[containerView class]);

	if(CGRectEqualToRect(self.bounds, CGRectZero))
		self.bounds = containerView.bounds; // Set my size to the default size.
	else
		containerView.bounds = self.bounds; // Sesize the container to my size so that the subviews are autoresized.
		
	for (UIView * view in containerView.subviews)
		[self addSubview:view];
}

@end

/****************************************************************************/
#pragma mark NibLoadedView

@implementation NibLoadedView : UIView

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	[self loadContentsFromNib];
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	[self loadContentsFromNib];
    return self;
}

@end
