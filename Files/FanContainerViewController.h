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

- (IBAction) showBackViewController;
- (IBAction) showFrontViewController;
- (IBAction) switchVisibleViewController;

@end
