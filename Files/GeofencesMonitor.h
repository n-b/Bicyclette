//
//  GeofencesMonitor.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@class Geofence;
@protocol GeofencesMonitorDelegate;

// GeofencesMonitor
//
// observe a list of geofences
@interface GeofencesMonitor : NSObject
- (void) addFence:(Geofence*)fence;
- (void) removeFence:(Geofence*)fence;

@property (weak) id<GeofencesMonitorDelegate> delegate;
@end

@protocol GeofencesMonitorDelegate <NSObject>

- (void) monitor:(GeofencesMonitor*)monitor fenceWasEntered:(Geofence*)fence;
- (void) monitor:(GeofencesMonitor*)monitor fenceWasExited:(Geofence*)fence;

@end


@interface Geofence : NSObject <MKAnnotation>
@property CLRegion * region;
@property NSString * identifier;
// To remove (used in MapVC)
@property (nonatomic,readonly) MKCoordinateRegion radarRegion;
@end

