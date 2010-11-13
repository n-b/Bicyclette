//
//  StationCell.m
//  Bicyclette
//
//  Created by Nicolas on 10/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "StationCell.h"
#import "VelibDataManager.h"
#import "Station.h"

@interface StationCell()
@end

@implementation StationCell

@synthesize nameLabel, addressLabel;
@synthesize availableCountLabel, freeCountLabel, totalCountLabel;
@synthesize refreshDateLabel;
@synthesize favoriteButton;
@synthesize station;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)dealloc {
	self.station = nil;
    [super dealloc];
}


- (void) setStation:(Station*)value
{
	[station autorelease];
	station = [value retain];
	self.nameLabel.text = self.station.name;
	self.addressLabel.text = self.station.address;
	self.availableCountLabel.text = [NSString stringWithFormat:@"%d",self.station.status_availableValue];
	self.freeCountLabel.text = [NSString stringWithFormat:@"%d",self.station.status_freeValue];
	self.totalCountLabel.text = [NSString stringWithFormat:@"%d",self.station.status_totalValue];
	self.refreshDateLabel.text = [self.station.status_date description];
	self.favoriteButton.backgroundColor = self.station.favorite?[UIColor redColor]:[UIColor whiteColor];
}

- (IBAction) switchFavorite
{
	self.station.favorite = !self.station.favorite;
}


@end
