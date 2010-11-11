//
//  UITableViewCell+EasyReuse.h
//

#import <UIKit/UIKit.h>

/****************************************************************************/
#pragma mark -

@interface UITableViewCell (EasyReuse)

// Cell Factory : will either dequeue a cell from the tableview or load a new one from the nib.
//
// Class method : call it on a UITableViewCell subclass.
// The reuse identifier will be the cell class name.
// The xib name must be exactly the same as the cell class name.
//
// Example use : [SomeCellSubclass reusableCellForTable:someTableView]
// * There must be a UITableViewCell subclass called SomeCellSubclass,
// * There must be a SomeCellSubclass.nib in your app,
// * The first object in the nib must be a SomeCellSubclass instance.
//
+ (id) reusableCellForTable:(UITableView*)tableView;

@end

@interface UIView (EasyNibLoading)

// loads a view from a same-named nib file.
+ (id) viewFromNib;

+ (id) viewFromNibNamed:(NSString*)nibName;

@end
