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

/****************************************************************************/
#pragma mark Private Methods

@interface BicycletteApplicationDelegate()
@property (strong) VelibModel * model;

@property (strong) IBOutlet MapVC *mapVC;
@property (strong) IBOutlet UILabel *notificationLabel;

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

@end
