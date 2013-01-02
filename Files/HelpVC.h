//
//  HelpVC.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 23/08/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@protocol HelpVCDelegate;

@interface HelpVC : UIViewController
@property (weak) IBOutlet id<HelpVCDelegate> delegate;
@end

@protocol HelpVCDelegate <NSObject>
- (void) helpFinished:(HelpVC*)helpVC;
@end
