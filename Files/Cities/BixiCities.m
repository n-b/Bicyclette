//
//  BixiCities
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BixiCities.h"

@implementation MontrealBixiCity
- (NSString *) title { return @"BIXI"; }
- (NSArray *) updateURLStrings { return @[@"http://montreal.bixi.com/data/bikeStations.xml"]; }
@end

@implementation TorontoBixiCity
- (NSString *) title { return @"BIXI"; }
- (NSArray *) updateURLStrings { return @[@"http://toronto.bixi.com/data/bikeStations.xml"]; }
@end

@implementation OttawaBixiCity
- (NSString *) title { return @"BIXI"; }
- (NSArray *) updateURLStrings { return @[@"http://capitale.bixi.com/data/bikeStations.xml"]; }
@end

@implementation LondonCycleHireCity
- (NSString *) title { return @"Cycle Hire"; }
- (NSArray *) updateURLStrings { return @[@"http://www.tfl.gov.uk/tfl/syndication/feeds/cycle-hire/livecyclehireupdates.xml"]; }
@end

@implementation WashingtonBikeShareCity
- (NSString *) title { return @"Capital Bike Share"; }
- (NSArray *) updateURLStrings { return @[@"http://capitalbikeshare.com/data/stations/bikeStations.xml"]; }
@end

@implementation BostonHubwayCity
- (NSString *) title { return @"Hubway"; }
- (NSArray *) updateURLStrings { return @[@"http://www.thehubway.com/data/stations/bikeStations.xml"]; }
@end

@implementation MinneapolisNiceRideCity
- (NSString *) title { return @"Nice Ride"; }
- (NSArray *) updateURLStrings { return @[@"https://secure.niceridemn.org/data2/bikeStations.xml"]; }
@end

