//
//  FanContainerViewController.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 03/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@interface FanContainerViewController : UIViewController

@property (nonatomic) IBOutlet UIViewController * frontViewController;
@property (nonatomic) IBOutlet UIViewController * backViewController;

-(CGPoint) rotationCenter; // default value returns the view center

@property (readonly) UIViewController * visibleViewController;

- (IBAction) switchVisibleViewController;
- (IBAction) showBackViewController;
- (IBAction) showFrontViewController;

- (void) switchVisibleViewControllerAnimated:(BOOL)animated completion:(void(^)(void)) completion;
- (void) showBackViewControllerAnimated:(BOOL)animated completion:(void(^)(void)) completion;
- (void) showFrontViewControllerAnimated:(BOOL)animated completion:(void(^)(void)) completion;
@end


@interface UIViewController (FanContainedViewController)
- (BOOL) isVisibleViewController;// returns YES if the receiver is the current visibleVC
@end
