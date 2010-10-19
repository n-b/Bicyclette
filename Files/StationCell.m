//
//  StationCell.m
//  Bicyclette
//
//  Created by Nicolas on 10/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "StationCell.h"
#import "VelibDataManager.h"

@implementation StationCell

@synthesize nameLabel, addressLabel;
@synthesize availableCountLabel, freeCountLabel, totalCountLabel;
@synthesize refreshDateLabel;
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
	self.availableCountLabel.text = [NSString stringWithFormat:@"%d",self.station.available];
	self.freeCountLabel.text = [NSString stringWithFormat:@"%d",self.station.free];
	self.totalCountLabel.text = [NSString stringWithFormat:@"%d",self.station.total];
	self.refreshDateLabel.text = [self.station.refreshDate description];
}

@end
