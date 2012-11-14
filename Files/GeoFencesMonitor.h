//
//  GeoFencesMonitor.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@protocol GeoFence;

// GeoFencesMonitor
//
// observe a list of geofences
@interface GeoFencesMonitor : NSObject
- (void) addFence:(id<GeoFence>)fence;
- (void) removeFence:(id<GeoFence>)fence;
- (void) setFences:(NSSet *)geofences;
@end


@protocol GeoFence <NSObject>

@property (readonly) CLRegion* region;

- (void) enterFence;
- (void) exitFence;

@end
