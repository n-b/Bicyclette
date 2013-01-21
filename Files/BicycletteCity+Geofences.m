//
//  BicycletteCity+Geofences.m
//  Bicyclette
//
//  Created by Nicolas @ bou.io on 21/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity+Geofences.h"
#import "CollectionsAdditions.h"

@implementation BicycletteCity (Geofences)
static char kBicycletteCity_associatedGeofencesKey;

- (void) updateFences
{
    NSMutableArray * newFences = [NSMutableArray new];
    
    // Group near starred stations
    NSArray * starredStations = [Station fetchStarredStations:self.mainContext];
    for (Station * station in starredStations) {
        __block Geofence * firstFoundFence = nil;

        // Find all fences with at least one near station to the current station
        [newFences enumerateObjectsUsingBlock:
         ^(Geofence* fence, NSUInteger idx, BOOL *stop) {
             __block BOOL didAddStationToFence = NO;
             [fence.pointsToUpdate enumerateObjectsUsingBlock:
              ^(Station* stationInFence, NSUInteger idx2, BOOL *stop2) {
                  CLLocationDistance distance = [stationInFence.location distanceFromLocation:station.location];
                  if(distance < 150)
                  {
                      didAddStationToFence = YES;
                      *stop2 = YES;
                  }
              }];
             if(didAddStationToFence)
             {
                 if(firstFoundFence==nil)
                 {
                     firstFoundFence = fence;
                     firstFoundFence.pointsToUpdate = [firstFoundFence.pointsToUpdate arrayByAddingObject:station];
                 }
                 else
                 {
                     // unite both fences
                     firstFoundFence.pointsToUpdate = [firstFoundFence.pointsToUpdate arrayByAddingObjectsFromArray:fence.pointsToUpdate];
                     fence.pointsToUpdate = @[];
                 }
             }
         }];
        if(!firstFoundFence)
        {
            Geofence * fence = [Geofence new];
            fence.pointsToUpdate = @[station];
            [newFences addObject:fence];
        }
    }
    
    // Clear empty fences
    for (Geofence * fence in [newFences copy]) {
        if([fence.pointsToUpdate count]==0)
            [newFences removeObject:fence];
    }
    
    // Set all fences properties
    for (Geofence * fence in newFences) {
        NSString * identifier = [[fence.pointsToUpdate valueForKeyPath:StationAttributes.number] componentsJoinedByString:@","];
        
        CLLocationDegrees latitude = [[@[[fence.pointsToUpdate valueForKeyPath:@"@min.latitude"],
                                       [fence.pointsToUpdate valueForKeyPath:@"@max.latitude"]] valueForKeyPath:@"@avg.self"] doubleValue];
        CLLocationDegrees longitude = [[@[[fence.pointsToUpdate valueForKeyPath:@"@min.longitude"],
                                        [fence.pointsToUpdate valueForKeyPath:@"@max.longitude"]] valueForKeyPath:@"@avg.self"] doubleValue];
        
        CLLocation * center = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        __block CLLocationDistance radius = 100;
        [fence.pointsToUpdate enumerateObjectsUsingBlock:^(Station* station, NSUInteger idx, BOOL *stop) {
            radius = MAX(radius, [station.location distanceFromLocation:center]);
        }];
        
        radius = radius + 50;
        fence.region = [[CLRegion alloc] initCircularRegionWithCenter:center.coordinate radius:radius identifier:identifier];
    }
    
    // reuse old objects if they are identical
    NSArray * oldFences = objc_getAssociatedObject(self, &kBicycletteCity_associatedGeofencesKey);
    NSArray * newIDs = [newFences valueForKeyPath:@"region.identifier"];
    NSArray * oldIDs = [oldFences valueForKeyPath:@"region.identifier"];
    NSMutableArray * fences = [NSMutableArray arrayWithArray:oldFences];
    for (Geofence * fence in [oldFences copy]) {
        if( ! [newIDs containsObject:fence.region.identifier])
        {
            [fences removeObject:fence];
        }
    }
    
    for (Geofence * fence in newFences) {
        if( ! [oldIDs containsObject:fence.region.identifier])
        {
            [fences addObject:fence];
        }
    }
    
    objc_setAssociatedObject(self, &kBicycletteCity_associatedGeofencesKey, fences, OBJC_ASSOCIATION_RETAIN);
}

- (NSArray*) geofences
{
    NSArray * geofences = objc_getAssociatedObject(self, &kBicycletteCity_associatedGeofencesKey);
    if(geofences==nil)
        [self updateFences];
    return objc_getAssociatedObject(self, &kBicycletteCity_associatedGeofencesKey);
}
@end


/****************************************************************************/
#pragma mark Geofence (LocalUpdateGroup)

@implementation Geofence (LocalUpdateGroup)

static char kGeoFence_associatedPointsToUpdateKey;
- (void) setPointsToUpdate:(NSArray*)property_ {
    objc_setAssociatedObject(self, &kGeoFence_associatedPointsToUpdateKey, property_, OBJC_ASSOCIATION_RETAIN);
}

- (NSArray *)pointsToUpdate {
    return objc_getAssociatedObject(self, &kGeoFence_associatedPointsToUpdateKey);
}

- (CLLocation*) location
{
    return [[CLLocation alloc] initWithLatitude:self.region.center.latitude longitude:self.region.center.longitude];
}

- (CLLocationDistance) radius
{
    return self.region.radius;
}

@end
