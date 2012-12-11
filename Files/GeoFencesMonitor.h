//
//  GeoFencesMonitor.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@protocol GeoFence;
@protocol GeoFencesMonitorDelegate;

// GeoFencesMonitor
//
// observe a list of geofences
@interface GeoFencesMonitor : NSObject
- (void) addFence:(id<GeoFence>)fence;
- (void) removeFence:(id<GeoFence>)fence;

@property (weak) id<GeoFencesMonitorDelegate> delegate;
@end

@protocol GeoFencesMonitorDelegate <NSObject>

- (void) monitor:(GeoFencesMonitor*)monitor fenceWasEntered:(id<GeoFence>)fence;
- (void) monitor:(GeoFencesMonitor*)monitor fenceWasExited:(id<GeoFence>)fence;

@end


@protocol GeoFence <NSObject>

@property (readonly) CLRegion* fenceRegion;

@end
