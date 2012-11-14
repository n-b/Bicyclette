//
//  RadarUpdateQueue.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 16/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@protocol LocalUpdateGroup;

@interface LocalUpdateQueue : NSObject
@property (nonatomic) CLLocation * referenceLocation;
- (void) addGroup:(id<LocalUpdateGroup>)group;
- (void) removeGroup:(id<LocalUpdateGroup>)group;

- (void) setGroups:(NSSet*)groups;
@end


@protocol LocalUpdateGroup <NSObject>
@property (readonly) CLLocation * location;
@property (readonly) NSSet* updatePoints;
@property (readonly) BOOL wantsSummary;
@end

@protocol LocalUpdatePoint <NSObject>
@property (readonly) CLLocation * location;
- (void) update;
@property (readonly) BOOL loading;
@end
