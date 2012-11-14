//
//  Radar+LocalUpdateGroup.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 14/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "Radar+LocalUpdateGroup.h"

@implementation Radar (LocalUpdateGroup)
- (CLLocation *) location
{
    return [[CLLocation alloc] initWithLatitude:self.latitudeValue longitude:self.longitudeValue];
}

+ (NSSet *)keyPathsForValuesAffectingLocation
{
    return [NSSet setWithObjects:@"latitude", @"longitude",nil];
}

- (NSSet *) updatePoints
{
    return [NSSet setWithArray:self.stationsWithinRadarRegion];
}

@dynamic wantsSummary;
@end
