//
//  StationDetailVC.m
//  Bicyclette
//
//  Created by Nicolas on 30/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "StationDetailVC.h"
#import "Station.h"
#import "StationStatusView.h"
#import "Locator.h"
#import "BicycletteApplicationDelegate.h"
#import "CLLocation+Direction.h"

#define kBounceLimit 100

/****************************************************************************/
#pragma mark -

@interface StationDetailVC () <UIScrollViewDelegate>
@property (nonatomic, retain) NSArray * stations;

- (BOOL) canShowPrevious;
- (BOOL) canShowNext;
- (void) showPreviousStation;
- (void) showNextStation;

- (void) stopBouncing;
- (void) restoreBouncing;

- (void) updateUI;
- (void) locationDidChange:(NSNotification*)notif;
@end

/****************************************************************************/
#pragma mark -

@implementation StationDetailVC

@synthesize scrollView, contentView;
@synthesize numberLabel, shortNameLabel, addressLabel, distanceLabel;
@synthesize statusView, loadingIndicator, statusDateLabel;
@synthesize favoriteButton;
@synthesize previousNextBarItem, previousNextControl;
@synthesize station, stations;

/****************************************************************************/
#pragma mark Life Cycle

+ (id) detailVCWithStation:(Station*) aStation inArray:(NSArray*)aStations
{
	return [[[self alloc] initWithStation:aStation inArray:aStations] autorelease];
}

- (id) initWithStation:(Station*) aStation inArray:(NSArray*)aStations
{
	self = [super initWithNibName:nil bundle:nil];
    if (self) {
		self.stations = aStations;
		self.station = aStation;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:)
													 name:LocationDidChangeNotification object:BicycletteAppDelegate.locator];
		self.wantsFullScreenLayout = YES;
    }
    return self;	
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	[self doesNotRecognizeSelector:_cmd];
	return nil;	
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.station = nil;
	self.stations = nil;
	self.previousNextBarItem = nil;
    [super dealloc];
}

/****************************************************************************/
#pragma mark View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.statusView.displayOtherSpots = YES;
	self.statusView.station = self.station;
	if(self.stations!=nil)
		self.navigationItem.rightBarButtonItem = self.previousNextBarItem;
	
	self.scrollView.contentSize = self.contentView.bounds.size;
	[self updateUI];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	self.previousNextBarItem = nil;
}


/****************************************************************************/
#pragma mark UI

- (BOOL) canShowPrevious
{
	return [self.stations indexOfObject:self.station] > 0;
}

- (BOOL) canShowNext
{
	return [self.stations indexOfObject:self.station] < self.stations.count-1;
}

- (void) showPreviousStation
{
	NSAssert([self canShowPrevious],@"wrong index");
	CATransition * animation = [CATransition animation];
	animation.type = kCATransitionPush;
	animation.subtype = kCATransitionFromBottom;
	[self.scrollView.layer addAnimation:animation forKey:@"previous"];
	self.station = [self.stations objectAtIndex:[self.stations indexOfObject:self.station]-1];
}

- (void) showNextStation
{
	NSAssert([self canShowNext],@"wrong index");
	CATransition * animation = [CATransition animation];
	animation.type = kCATransitionPush;
	animation.subtype = kCATransitionFromTop;
	[self.scrollView.layer addAnimation:animation forKey:@"next"];
	self.station = [self.stations objectAtIndex:[self.stations indexOfObject:self.station]+1];
}

- (void) setStation:(Station*)value
{
	[self.station removeObserver:self forKeyPath:@"loading"];
	[self.station removeObserver:self forKeyPath:@"status_date"];
	[self.station removeObserver:self forKeyPath:@"favorite"];
	[station autorelease];
	station = [value retain];
	if(self.station)
	{
		NSAssert1([self.stations indexOfObject:self.station]!=NSNotFound,@"invalid station %@",self.station);
		[self.station addObserver:self forKeyPath:@"favorite" options:0 context:[StationDetailVC class]];
		[self.station addObserver:self forKeyPath:@"status_date" options:0 context:[StationDetailVC class]];
		[self.station addObserver:self forKeyPath:@"loading" options:0 context:[StationDetailVC class]];
		self.statusView.station = self.station;
		[self.station refresh];
		[self updateUI];
	}
}

- (void) updateUI
{
	self.title = [NSString stringWithFormat:NSLocalizedString(@"Station %@",@""),self.station.number];
	self.numberLabel.text = self.station.name;
//	self.shortNameLabel.text = self.station.cleanName;
	self.addressLabel.text = self.station.fullAddress;
	self.distanceLabel.text = [self.station.location routeDescriptionFromLocation:BicycletteAppDelegate.locator.location usingShortFormat:NO];

	[self.statusView setNeedsDisplay];
	if(self.station.loading)
		[self.loadingIndicator startAnimating];
	else
		[self.loadingIndicator stopAnimating];
	self.statusDateLabel.text = self.station.statusDateDescription;
	
	self.favoriteButton.selected = self.station.favorite;
	
	[self.previousNextControl setEnabled:[self canShowPrevious] forSegmentAtIndex:0];
	[self.previousNextControl setEnabled:[self canShowNext] forSegmentAtIndex:1];
	
}

/****************************************************************************/
#pragma mark Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView*) scrollView
{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if(self.scrollView.contentOffset.y < -kBounceLimit && [self canShowPrevious])
	{	
		[self showPreviousStation];
		[self stopBouncing];
	}
	else if(self.scrollView.contentOffset.y > kBounceLimit && [self canShowNext])
	{
		[self showNextStation];
		[self stopBouncing];
	}
}

- (void) stopBouncing
{
	self.scrollView.contentOffset = CGPointZero;
	self.scrollView.bounces = NO;
	[self performSelector:@selector(restoreBouncing) withObject:nil afterDelay:0.5];
}

- (void) restoreBouncing
{
	self.scrollView.bounces = YES;
}

/****************************************************************************/
#pragma mark Actions

- (IBAction) switchFavorite
{
	self.station.favorite = !self.station.favorite;
}

- (IBAction) changeToPreviousNext
{
	if(self.previousNextControl.selectedSegmentIndex==0)
		[self showPreviousStation];
	else
		[self showNextStation];
}

/****************************************************************************/
#pragma mark data changes

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == [StationDetailVC class])
	{
		if(object==self.station)
			[self updateUI];			
	}
	else 
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void) locationDidChange:(NSNotification*)notif
{
	[self updateUI];
}

@end
