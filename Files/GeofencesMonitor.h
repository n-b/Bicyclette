//
//  GeofencesMonitor.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@class Geofence;
@protocol GeofencesMonitorDelegate;
@class BicycletteCity;

#import "LocalUpdateQueue.h"

// GeofencesMonitor
//
// observe a list of geofences
@interface GeofencesMonitor : NSObject

- (void) setStarredStations:(NSArray*)stations inCity:(BicycletteCity*)city;
- (NSArray*) geofencesInCity:(BicycletteCity*)city;

@property (weak) id<GeofencesMonitorDelegate> delegate;
@end

@protocol GeofencesMonitorDelegate <NSObject>

- (void) monitor:(GeofencesMonitor*)monitor fenceWasEntered:(Geofence*)fence;
- (void) monitor:(GeofencesMonitor*)monitor fenceWasExited:(Geofence*)fence;
- (void) monitor:(GeofencesMonitor*)monitor fenceMonitoringFailed:(Geofence*)fence withError:(NSError*)error;

@end


@interface Geofence : NSObject <MKOverlay, LocalUpdateGroup>
@property CLCircularRegion * region;
@property (nonatomic, readonly) BicycletteCity * city;
@property (nonatomic, readonly) NSArray * stations;
@end

