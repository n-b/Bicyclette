//
//  StationCell.m
//  Bicyclette
//
//  Created by Nicolas on 10/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "StationCell.h"
#import "StationStatusView.h"
#import "Station.h"
#import "Locator.h"
#import "BicycletteApplicationDelegate.h"
#import "CLLocation+Direction.h"

/****************************************************************************/
#pragma mark Private Methods

@interface StationCell()
- (void) updateUI;
- (void) locationDidChange:(NSNotification*)notif;
@end

/****************************************************************************/
#pragma mark -

@implementation StationCell

@synthesize shortNameLabel, availableCountLabel, freeCountLabel;
@synthesize statusView, loadingIndicator;
@synthesize favoriteButton;
@synthesize station;

/****************************************************************************/
#pragma mark Life Cycle

- (void) awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:)
												 name:LocationDidChangeNotification object:BicycletteAppDelegate.locator];
	NSAssert(self.bounds.size.height==StationCellHeight,@"wrong cell height");
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.station = nil;
    [super dealloc];
}

/****************************************************************************/
#pragma mark UI

- (void) setStation:(Station*)value
{
	[self.station removeObserver:self forKeyPath:@"loading"];
	[self.station removeObserver:self forKeyPath:@"favorite"];
	[station autorelease];
	station = [value retain];
	[self.station addObserver:self forKeyPath:@"favorite" options:0 context:[StationCell class]];
	[self.station addObserver:self forKeyPath:@"loading" options:0 context:[StationCell class]];
	self.statusView.station = self.station;
	[self updateUI];
}

- (void) updateUI
{
	self.shortNameLabel.text = self.station.cleanName;
	self.availableCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d Vélos", nil),self.station.status_availableValue];
	self.freeCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d Places", nil),self.station.status_freeValue];

    self.loadingIndicator.hidden = !self.station.loading;
    self.availableCountLabel.hidden = self.freeCountLabel.hidden = self.station.loading;
		
	self.favoriteButton.selected = self.station.favorite;
}

/****************************************************************************/
#pragma mark Actions

- (IBAction) switchFavorite
{
	self.station.favorite = !self.station.favorite;
}

/****************************************************************************/
#pragma mark data changes

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == [StationCell class])
		[self updateUI];
	else 
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void) locationDidChange:(NSNotification*)notif
{
	[self updateUI];
}

@end
