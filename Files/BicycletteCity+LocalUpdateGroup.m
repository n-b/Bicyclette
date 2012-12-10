//
//  BicycletteCity+LocalUpdateGroup.m
//  Bicyclette
//
//  Created by Nicolas on 10/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity+LocalUpdateGroup.h"

/****************************************************************************/
#pragma mark -

@implementation Radar (LocalUpdateGroup)
- (CLLocation *) location
{
    return [[CLLocation alloc] initWithLatitude:self.latitudeValue longitude:self.longitudeValue];
}

+ (NSSet *)keyPathsForValuesAffectingUpdatePoints
{
    return [NSSet setWithObjects:@"latitude", @"longitude",nil];
}

- (NSSet *) updatePoints
{
    return [NSSet setWithArray:self.stationsWithinRadarRegion];
}

@dynamic wantsSummary;
@end


@implementation Station (LocalUpdatePoint)
@dynamic location, loading;
- (void) update
{
    [self refresh];
}
@end

@interface LocalUpdateGroup ()
@property MKCoordinateRegion region;
@end

@implementation LocalUpdateGroup
- (CLLocation *) location
{
    return [[CLLocation alloc] initWithLatitude:self.region.center.latitude longitude:self.region.center.longitude];
}
- (BOOL) wantsSummary
{
    return NO;
}
- (NSArray*) updatePoints
{
    return [self.city stationsWithinRegion:self.region];
}

+ (NSSet *)keyPathsForValuesAffectingUpdatePoints
{
    return [NSSet setWithObjects:@"city",@"region", nil];
}
@end
