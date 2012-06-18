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

/****************************************************************************/
#pragma mark Private Methods

@interface BicycletteApplicationDelegate()

@property (strong) IBOutlet UIView *notificationView;
@property (strong) IBOutlet UILabel *notificationLabel;
@property (strong) IBOutlet UIButton *notificationButton;
@property (strong) VelibModel * model;

@end

/****************************************************************************/
#pragma mark -

@implementation BicycletteApplicationDelegate

@synthesize window, notificationView, notificationLabel, notificationButton;
@synthesize model;

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
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// notification view
	self.notificationView.layer.cornerRadius = 10;
	[self.window addSubview:self.notificationView];
	self.notificationView.center = self.window.center;

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
    self.notificationView.alpha = 0;
    [self.model updateIfNeeded];
}

/****************************************************************************/
#pragma mark CoreDataManager delegate

- (void) modelUpdated:(NSNotification*)note
{
    [UIView beginAnimations:nil context:NULL];
    self.notificationView.alpha = 1;
    if([note.name isEqualToString:VelibModelNotifications.updateBegan])
    {
        self.notificationButton.userInteractionEnabled = NO;
        self.notificationLabel.text = NSLocalizedString(@"UPDATING : FETCHING", nil);
    }
    else if([note.name isEqualToString:VelibModelNotifications.updateGotNewData])
    {
        self.notificationButton.userInteractionEnabled = NO;
        self.notificationLabel.text = NSLocalizedString(@"UPDATING : PARSING", nil);
    }
    else if([note.name isEqualToString:VelibModelNotifications.updateSucceeded])
    {
        self.notificationButton.userInteractionEnabled = YES;
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
        self.notificationButton.userInteractionEnabled = YES;
        self.notificationLabel.text = [NSString stringWithFormat:NSLocalizedString(@"UPDATING : FAILED %@", nil),
                                       note.userInfo[VelibModelNotifications.keys.failureReason]];
    }
    [UIView commitAnimations];
}

- (IBAction)hideNotification:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    self.notificationView.alpha = 0;
    [UIView commitAnimations];
}

@end
