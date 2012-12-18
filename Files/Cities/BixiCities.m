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
- (NSString *) titleForStation:(Station *)station { return station.name; }
- (NSArray *) updateURLStrings { return @[@"http://montreal.bixi.com/data/bikeStations.xml"]; }
@end

@implementation BostonHubwayCity
- (NSString *) title { return @"Hubway"; }
- (NSString *) titleForStation:(Station *)station { return station.name; }
- (NSArray *) updateURLStrings { return @[@"http://www.thehubway.com/data/stations/bikeStations.xml"]; }
@end
