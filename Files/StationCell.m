//
//  StationCell.m
//  Bicyclette
//
//  Created by Nicolas on 10/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "StationCell.h"
#import "Station.h"
#import "BicycletteApplicationDelegate.h"

/****************************************************************************/
#pragma mark Private Methods

@interface StationCell()
- (void) updateUI;
- (void) locationDidChange:(NSNotification*)notif;
@end

/****************************************************************************/
#pragma mark -

@implementation StationCell

@synthesize nameLabel, addressLabel;
@synthesize availableCountLabel, freeCountLabel, totalCountLabel;
@synthesize refreshDateLabel;
@synthesize favoriteButton;
@synthesize station;

/****************************************************************************/
#pragma mark Life Cycle

- (void) awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:)
												 name:LocationDidChangeNotification object:nil];
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
	[station autorelease];
	[station removeObserver:self forKeyPath:@"status_date"];
	[station removeObserver:self forKeyPath:@"favorite"];
	station = [value retain];
	[station addObserver:self forKeyPath:@"status_date" options:0 context:[StationCell class]];
	[station addObserver:self forKeyPath:@"favorite" options:0 context:[StationCell class]];
	[self updateUI];
}

- (void) updateUI
{
	self.nameLabel.text = self.station.name;
	self.addressLabel.text = self.station.address;
	self.availableCountLabel.text = [NSString stringWithFormat:@"%d",self.station.status_availableValue];
	self.freeCountLabel.text = [NSString stringWithFormat:@"%d",self.station.status_freeValue];
	self.totalCountLabel.text = [NSString stringWithFormat:@"%d",self.station.status_totalValue];
	self.refreshDateLabel.text = [self.station.status_date description];
	self.favoriteButton.backgroundColor = self.station.favorite?[UIColor redColor]:[UIColor whiteColor];
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
