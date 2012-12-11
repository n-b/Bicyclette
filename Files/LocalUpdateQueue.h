//
//  RadarUpdateQueue.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 16/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@protocol LocalUpdateGroup, LocalUpdatePoint, LocalUpdateQueueDelegate;
#import "NSArray+Locatable.h"

// Queue
@interface LocalUpdateQueue : NSObject
@property (nonatomic) CLLocation * referenceLocation;
@property NSTimeInterval delayBetweenPointUpdates;

// Monitored Update Groups
@property (nonatomic) CLLocationDistance moniteredGroupsMaximumDistance;
- (void) addMonitoredGroup:(NSObject<LocalUpdateGroup>*)group;
- (void) removeMonitoredGroup:(NSObject<LocalUpdateGroup>*)group;

// One-shot Update Groups
- (void) addOneshotGroup:(NSObject<LocalUpdateGroup>*)group;
- (void) removeOneshotGroup:(NSObject<LocalUpdateGroup>*)group;

@property (weak) id<LocalUpdateQueueDelegate> delegate;
@end

// delegate
@protocol LocalUpdateQueueDelegate <NSObject>
- (void) updateQueue:(LocalUpdateQueue *)queue didUpdateOneshotPoint:(id<LocalUpdatePoint>)point ofGroup:(id<LocalUpdateGroup>)group;
@end

// Update Group
@protocol LocalUpdateGroup <NSObject, Locatable>
@property (readonly) CLLocation * location;
@property (readonly) NSArray * pointsToUpdate;
@end

// Update Point
@protocol LocalUpdatePoint <NSObject>
@property (readonly) CLLocation * location;
- (void) updateWithCompletionBlock:(void(^)())completion;
@property BOOL queuedForUpdate;
@end



