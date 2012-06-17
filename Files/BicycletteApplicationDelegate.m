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

@interface BicycletteApplicationDelegate() <CoreDataManagerDelegate>

@property (nonatomic, strong) IBOutlet UIView *notificationView;

@property (nonatomic, strong) VelibModel * model;

@end

/****************************************************************************/
#pragma mark -

@implementation BicycletteApplicationDelegate

@synthesize window, notificationView;
@synthesize model;

/****************************************************************************/
#pragma mark Application lifecycle

- (void) awakeFromNib
{
	// Load Factory Defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"FactoryDefaults" ofType:@"plist"]]];

    // Create model
    self.model = [VelibModel new];
    self.model.delegate = self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// notification view
	self.notificationView.layer.cornerRadius = 10;
	[self.window addSubview:self.notificationView];
	self.notificationView.center = self.window.center;
    [self.model addObserver:self forKeyPath:@"updater.downloadingUpdate" options:NSKeyValueObservingOptionInitial context:(__bridge void *)([BicycletteApplicationDelegate class])];

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

- (void)dealloc {
	[self.model removeObserver:self forKeyPath:@"updater.downloadingUpdate"];
}

/****************************************************************************/
#pragma mark CoreDataManager delegate

- (void) coreDataManager:(CoreDataManager*)manager didSave:(BOOL)success withErrors:(NSArray*)errors
{
    if(errors.count)
    {
        NSString * title = success ? NSLocalizedString(@"Some invalid data could not be saved.", 0) : NSLocalizedString(@"Invalid data prevented data to be saved.", 0);
        NSMutableString * message = [NSMutableString string];
        for (NSError * error in errors) {
            [message appendFormat:@"%@ : %@\n",error.localizedDescription,error.localizedFailureReason];
        }
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", 0) otherButtonTitles:nil];
        [alert show];
    }
}

/****************************************************************************/
#pragma mark -

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([BicycletteApplicationDelegate class])) {
		[UIView beginAnimations:nil context:NULL];
		self.notificationView.alpha = self.model.updater.downloadingUpdate?1.f:0.f;
		[UIView commitAnimations];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end
