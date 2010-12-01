//
//  RegionCell.m
//  Bicyclette
//
//  Created by Nicolas on 01/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "RegionCell.h"
#import "Region.h"

@implementation RegionCell

@synthesize nameLabel, countLabel;
@synthesize region;

- (void)dealloc {
	self.region = nil;
    [super dealloc];
}


- (void) setRegion:(Region*)value
{
	[region autorelease];
	region = [value retain];
	self.nameLabel.text = self.region.longName;
	self.countLabel.text = [NSString stringWithFormat:@"%d",self.region.stations.count];
}

@end
