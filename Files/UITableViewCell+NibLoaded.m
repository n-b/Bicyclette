//
//  UITableViewCell+NibLoaded.m
//

#import "UITableViewCell+NibLoaded.h"

@implementation UITableViewCell (NibLoaded)

+ (id) reusableCellForTable:(UITableView*)tableView
{
	NSString * className = NSStringFromClass([self class]);
	id cell = [tableView dequeueReusableCellWithIdentifier:className];
	if(cell==nil)
	{
		NSArray * nibObjects = [[NSBundle mainBundle] loadNibNamed:className owner:nil options:nil];
		NSAssert1(nibObjects!=nil,@"Could not load nib named %@.nib",className);
		NSAssert1([nibObjects count]>0,@"No object found in %@.nib",className);
		cell = [nibObjects objectAtIndex:0];
		NSAssert3([cell isKindOfClass:[self class]], @"Wrong class in object in nib file %@.nib. Should be %@, found %@.",className,className,NSStringFromClass([cell class]));
		NSAssert3([[cell reuseIdentifier] isEqualToString:className], @"Wrong reuseIdentifier in object in nib file %@.nib. Should be %@, found %@.",className,className,[cell reuseIdentifier]);
	}
	return cell;
}

@end
