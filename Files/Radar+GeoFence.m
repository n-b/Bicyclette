//
//  Radar+GeoFence.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 14/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "Radar+GeoFence.h"

@implementation Radar (GeoFence)

+ (NSSet *)keyPathsForValuesAffectingRegion
{
    return [NSSet setWithObject:@"monitoringRegion"];
}
- (CLRegion*) region
{
    return [self monitoringRegion];
}

- (void) enterFence
{
    [self setWantsSummary];
}

- (void) exitFence
{
    [self clearWantsSummary];
}

@end
