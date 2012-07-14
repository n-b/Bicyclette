//
//  BicycletteApplicationDelegate.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteApplicationDelegate.h"
#import "VelibModel.h"
#import "DataUpdater.h"
#import "MapVC.h"
#import "PrefsVC.h"
#import "UIView+Screenshot.h"

/****************************************************************************/
#pragma mark Private Methods

@interface BicycletteApplicationDelegate()
@property (strong) VelibModel * model;

@property (strong) IBOutlet UINavigationController *rootNavC;
@property (strong) IBOutlet MapVC *mapVC;
@property (strong) IBOutlet PrefsVC *prefsVC;

@property (strong) UILabel *notificationLabel;

@property (strong) UIImageView *screenshot;
@property (weak) UIView *senderSuperview;
@property CGPoint senderCenter;
@end

/****************************************************************************/
#pragma mark -

@implementation BicycletteApplicationDelegate

/****************************************************************************/
#pragma mark Application lifecycle

- (void) awakeFromNib
{
	// Load Factory Defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"FactoryDefaults" ofType:@"plist"]]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelUpdated:) name:VelibModelNotifications.updateBegan object:self.model];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelUpdated:) name:VelibModelNotifications.updateGotNewData object:self.model];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelUpdated:) name:VelibModelNotifications.updateSucceeded object:self.model];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelUpdated:) name:VelibModelNotifications.updateFailed object:self.model];

    // Create model
    self.model = [VelibModel new];
    self.mapVC.model = self.model;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// notification view
    CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
    frame.origin.y = frame.size.height;
    self.notificationLabel = [[UILabel alloc] initWithFrame:frame];
    self.notificationLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:.83];
    self.notificationLabel.textColor = [UIColor colorWithWhite:.83 alpha:1];
    self.notificationLabel.shadowColor = [UIColor colorWithWhite:.0 alpha:.5];
    self.notificationLabel.textAlignment = NSTextAlignmentCenter;
    
    self.notificationLabel.font = [UIFont boldSystemFontOfSize:13];
	[self.window addSubview:self.notificationLabel];

	[self.window makeKeyAndVisible];

    // Fade animation
	UIView * fadeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
	[self.window addSubview:fadeView];
	[UIView beginAnimations:nil context:NULL];
	fadeView.alpha = 0;
	fadeView.transform = CGAffineTransformMakeScale(2, 2);
	[fadeView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1];
	[UIView commitAnimations];

	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    self.notificationLabel.hidden = YES;
    [self.model updateIfNeeded];
}

/****************************************************************************/
#pragma mark CoreDataManager delegate

- (void) modelUpdated:(NSNotification*)note
{
    self.notificationLabel.hidden = NO;
    if([note.name isEqualToString:VelibModelNotifications.updateBegan])
    {
        self.notificationLabel.text = NSLocalizedString(@"UPDATING : FETCHING", nil);
    }
    else if([note.name isEqualToString:VelibModelNotifications.updateGotNewData])
    {
        self.notificationLabel.text = NSLocalizedString(@"UPDATING : PARSING", nil);
    }
    else if([note.name isEqualToString:VelibModelNotifications.updateSucceeded])
    {
        BOOL newData = [note.userInfo[VelibModelNotifications.keys.dataChanged] boolValue];
        NSArray * saveErrors = note.userInfo[VelibModelNotifications.keys.saveErrors];
        if(saveErrors)
            self.notificationLabel.text = NSLocalizedString(@"UPDATING : COMPLETED WITH ERRORS", nil);
        else if(newData)
            self.notificationLabel.text = NSLocalizedString(@"UPDATING : COMPLETED", nil);
        else
            self.notificationLabel.text = NSLocalizedString(@"UPDATING : NO NEW DATA", nil);
        [self performSelector:@selector(hideNotification:) withObject:self afterDelay:2];
    }
    else if([note.name isEqualToString:VelibModelNotifications.updateFailed])
    {
        self.notificationLabel.text = [NSString stringWithFormat:NSLocalizedString(@"UPDATING : FAILED %@", nil),
                                       note.userInfo[VelibModelNotifications.keys.failureReason]];
    }
    [UIView commitAnimations];
}

- (IBAction)hideNotification:(id)sender {
    self.notificationLabel.hidden = YES;
}


- (IBAction)showInfo:(UIButton*)sender
{
    if(self.rootNavC.visibleViewController==self.mapVC)
    {
        CGPoint rotationCenter = [self.window convertPoint:sender.center fromView:sender.superview];
        self.senderSuperview = sender.superview;
        self.senderCenter = sender.center;
        [sender removeFromSuperview];
        
        // Take a screenshot of the presenting vc
        self.screenshot = [[UIImageView alloc] initWithImage:[self.window screenshot]];
        [self.window addSubview:self.screenshot];
        [self.screenshot addSubview:sender];
        self.screenshot.userInteractionEnabled = YES;
        sender.center = rotationCenter;
        self.screenshot.layer.borderWidth = 1;
        self.screenshot.layer.borderColor = [UIColor darkGrayColor].CGColor;
        
        // Present (not animated)
        [self.rootNavC presentViewController:self.prefsVC animated:NO completion:nil];
        
        self.screenshot.layer.anchorPoint = CGPointMake(rotationCenter.x/self.window.bounds.size.width,
                                                        rotationCenter.y/self.window.bounds.size.height);
        CGSize translation = CGSizeMake(rotationCenter.x-CGRectGetMidX(self.window.bounds),
                                        rotationCenter.y-CGRectGetMidY(self.window.bounds));
        self.screenshot.transform = CGAffineTransformMakeTranslation(translation.width, translation.height );
        
        // Animate
        [UIView animateWithDuration:.5
                         animations:^(void) {
                             CGAffineTransform rotation = CGAffineTransformMakeRotation(.8*M_PI);
                             self.screenshot.transform = CGAffineTransformConcat(rotation, self.screenshot.transform);
                             sender.transform = CGAffineTransformInvert(rotation);
                         } completion:^(BOOL finished) {
                             self.screenshot.layer.borderWidth = 0;
                             self.screenshot.layer.shadowOffset = CGSizeZero;
                             self.screenshot.layer.shadowRadius = 2;
                             self.screenshot.layer.shadowOpacity = 1;
                             self.screenshot.layer.shadowColor = [UIColor blackColor].CGColor;
                         }];
    }
    else
    {
        self.screenshot.layer.borderWidth = 1;
        self.screenshot.layer.shadowRadius = 0;
        self.screenshot.layer.shadowOpacity = 0;
        [UIView animateWithDuration:.5
                         animations:^(void) {
                             CGAffineTransform rotation = CGAffineTransformMakeRotation(-.8*M_PI);
                             self.screenshot.transform = CGAffineTransformConcat(rotation, self.screenshot.transform);
                             sender.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             [self.senderSuperview addSubview:sender];
                             sender.center = self.senderCenter;
                             self.senderSuperview = nil;
                             [self.screenshot removeFromSuperview];
                             self.screenshot = nil;
                             [self.rootNavC dismissViewControllerAnimated:NO completion:nil];
                         }];
    }
}
@end
