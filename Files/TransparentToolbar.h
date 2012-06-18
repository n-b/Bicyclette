//
//  TransparentToolbar.h
//  
//
//  Created by Nicolas Bouilleaud on 24/01/11.
//

#import <UIKit/UIKit.h>


// Very small UIToolbar subclass with no background. 
//
// Can be used for two things :
// * Customize the background of a toolbar, at the bottom of the screen, simply by using it instead of a regular UIToolbar and adding a background subview.
// 
// * Use as a custom view in a UIBarItem in a navbar, effectively allowing to have several UIBarItems in the navbar right or left item.
//   To do this, you need to create a UIBarButtonItem taking the tool bar as a custom view : 
//    someNavigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBar] autorelease];
//   On iPad, this would work as well with a regular UIToolbar.
//   On iPhone, this produces a 1-pixel glitch because the UINavigationBar and the UIToolbar are visually different.
//
// * Additionally, the tintColor is still taken into account in the toolbar's items, which can be used for some more customization.
@interface TransparentToolbar : UIToolbar
@end
