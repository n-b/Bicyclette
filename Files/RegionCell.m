//
//  RegionCell.m
//  Bicyclette
//
//  Created by Nicolas on 01/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "RegionCell.h"
#import "Region.h"

@interface RegionCell()
// Outlets
@property (nonatomic, weak) IBOutlet UILabel * nameLabel;
@property (nonatomic, weak) IBOutlet UILabel * numberLabel;
@property (nonatomic, weak) IBOutlet UILabel * countLabel;
@end

@implementation RegionCell

@synthesize nameLabel, numberLabel, countLabel;
@synthesize region;

- (void) awakeFromNib
{
	NSAssert(self.bounds.size.height==RegionCellHeight,@"wrong cell height");
}

- (void)dealloc {
	self.region = nil;
}


- (void) setRegion:(Region*)value
{
	region = value;
	self.nameLabel.text = self.region.name;
	self.numberLabel.text = self.region.number;
	self.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d stations",@""),self.region.stations.count];
}

@end
