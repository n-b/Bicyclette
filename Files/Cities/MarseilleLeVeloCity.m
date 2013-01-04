//
//  MarseilleLeVeloCity.m
//  Bicyclette
//
//  Created by Nicolas on 14/10/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CyclocityCity.h"
#import "BicycletteCity.mogenerated.h"

@interface MarseilleLeVeloCity : CyclocityCity
@end

@implementation MarseilleLeVeloCity

#pragma mark Annotations

- (NSString *) titleForRegion:(Region*)region { return [NSString stringWithFormat:@"%@°",region.number]; }
- (NSString *) subtitleForRegion:(Region*)region { return @"arr."; }

#pragma mark CyclocityCity

- (RegionInfo*) regionInfoFromStation:(Station*)station values:(NSDictionary*)values patchs:(NSDictionary*)patchs requestURL:(NSString*)urlString;
{
    return [RegionInfo infoWithName:[station.name substringToIndex:1]
                             number:[station.name substringToIndex:1]];
}

@end
