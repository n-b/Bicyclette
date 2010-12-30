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

/****************************************************************************/
#pragma mark -

@interface StationDetailVC ()
@property (nonatomic, retain) NSArray * stations;

- (void) updateUI;
- (void) locationDidChange:(NSNotification*)notif;
@end

/****************************************************************************/
#pragma mark -

@implementation StationDetailVC

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
	self.statusView.displayLegend = YES;
	self.statusView.station = self.station;
	self.navigationItem.rightBarButtonItem = self.previousNextBarItem;
	[self updateUI];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	self.previousNextBarItem = nil;
}


/****************************************************************************/
#pragma mark UI

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
	self.numberLabel.text = self.station.number;
	self.shortNameLabel.text = self.station.cleanName;
	self.addressLabel.text = self.station.fullAddress;
	self.distanceLabel.text = [self.station.location routeDescriptionFromLocation:BicycletteAppDelegate.locator.location usingShortFormat:NO];

	[self.statusView setNeedsDisplay];
	if(self.station.loading)
		[self.loadingIndicator startAnimating];
	else
		[self.loadingIndicator stopAnimating];
	self.statusDateLabel.text = self.station.statusDateDescription;
	
	self.favoriteButton.selected = self.station.favorite;
	
	NSUInteger index = [self.stations indexOfObject:self.station];
	[self.previousNextControl setEnabled:index>0 forSegmentAtIndex:0];
	[self.previousNextControl setEnabled:index<self.stations.count-1 forSegmentAtIndex:1];
}

/****************************************************************************/
#pragma mark Actions

- (IBAction) switchFavorite
{
	self.station.favorite = !self.station.favorite;
}

- (IBAction) changeToPreviousNext
{
	NSUInteger index = [self.stations indexOfObject:self.station];
	if(self.previousNextControl.selectedSegmentIndex==0)
		--index;
	else
		++index;
	self.station = [self.stations objectAtIndex:index];
}

/****************************************************************************/
#pragma mark data changes

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == [StationDetailVC class])
		[self updateUI];
	else 
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void) locationDidChange:(NSNotification*)notif
{
	[self updateUI];
}

@end
