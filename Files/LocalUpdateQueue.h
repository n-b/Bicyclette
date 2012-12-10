//
//  RadarUpdateQueue.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 16/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@protocol LocalUpdateGroup;
#import "NSArray+Locatable.h"


// Queue
@interface LocalUpdateQueue : NSObject
@property (nonatomic) CLLocation * referenceLocation;
- (void) addGroup:(id<LocalUpdateGroup>)group;
- (void) removeGroup:(id<LocalUpdateGroup>)group;

- (void) setGroups:(NSSet*)groups;
@end


// Update Group
@protocol LocalUpdateGroup <NSObject, Locatable>
@property (readonly) CLLocation * location;
@property (readonly) NSArray * updatePoints;
@property (readonly) BOOL wantsSummary;
@end

// Update Point
@protocol LocalUpdatePoint <NSObject>
@property (readonly) CLLocation * location;
- (void) update;
@property (readonly) BOOL loading;
@end



