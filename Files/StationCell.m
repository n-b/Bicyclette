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

@synthesize nameLabel, addressLabel, distanceLabel;
@synthesize statusView;
@synthesize favoriteButton;
@synthesize station;

/****************************************************************************/
#pragma mark Life Cycle

- (void) awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:)
												 name:LocationDidChangeNotification object:BicycletteAppDelegate.locator];
	NSAssert(self.bounds.size.height==100,@"wrong cell height");
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
	[self.station removeObserver:self forKeyPath:@"status_date"];
	[self.station removeObserver:self forKeyPath:@"favorite"];
	[station autorelease];
	station = [value retain];
	[self.station addObserver:self forKeyPath:@"favorite" options:0 context:[StationCell class]];
	[self.station addObserver:self forKeyPath:@"status_date" options:0 context:[StationCell class]];
	[self.station addObserver:self forKeyPath:@"loading" options:0 context:[StationCell class]];
	self.statusView.station = self.station;
	[self updateUI];
}

- (void) updateUI
{
	self.nameLabel.text = self.station.name;
	self.addressLabel.text = self.station.address;
	[self.statusView setNeedsDisplay];
	self.favoriteButton.selected = self.station.favorite;
	
	self.distanceLabel.text = [self.station.location routeDescriptionFromLocation:BicycletteAppDelegate.locator.location];
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
