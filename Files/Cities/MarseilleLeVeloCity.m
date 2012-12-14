//
//  MarseilleLeVeloCity.m
//  Bicyclette
//
//  Created by Nicolas on 14/10/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "MarseilleLeVeloCity.h"
#import "BicycletteCity.mogenerated.h"

@implementation MarseilleLeVeloCity

#pragma mark City Data Update

- (NSArray*) updateURLStrings { return @[ @"http://www.levelo-mpm.fr/service/carto" ]; }

#pragma mark Stations Individual Data Updates

- (NSString *) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.levelo-mpm.fr/service/stationdetails/marseille/%@",station.number]; }

#pragma mark Annotations

- (NSString*) title { return @"Le Vélo"; }
- (NSString*) titleForRegion:(Region*)region { return [NSString stringWithFormat:@"%@°",region.number]; }
- (NSString*) subtitleForRegion:(Region*)region { return @"arr."; }

#pragma mark CyclocityCity

- (RegionInfo*) regionInfoFromStation:(Station*)station patchs:(NSDictionary*)patchs
{
    RegionInfo * regionInfo = [RegionInfo new];
    regionInfo.number = [station.name substringToIndex:1];
    regionInfo.name = [station.name substringToIndex:1];
    return regionInfo;
}

@end
