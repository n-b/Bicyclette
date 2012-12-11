//
//  LocalUpdateQueueTests.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 17/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "LocalUpdateQueue.h"
#import "SenTestCase+RunLoop.h"

//
// Make NSDictionary conform to the protocols to use as our test objects
@interface NSDictionary (Locatable)  <Locatable, LocalUpdateGroup, LocalUpdatePoint>
@end
@implementation NSDictionary (Locatable)
- (id) location
{
    return self[@"location"];
}
- (NSArray*) pointsToUpdate
{
    return self[@"points"];
}
- (void) updateWithCompletionBlock:(void (^)())completion
{
    void (^updateblock)(id obj) = self[@"update"];
    if(updateblock)
        updateblock(self);
    completion();
}
- (BOOL) queuedForUpdate
{
    return [self[@"queuedForUpdate"] boolValue];
}
- (void) setQueuedForUpdate:(BOOL)queuedForUpdate
{
    ((NSMutableDictionary*)self)[@"queuedForUpdate"] = @(queuedForUpdate);
}
@end

//
// Tests
@interface NSArray_LocatableTests : SenTestCase
@end

@implementation NSArray_LocatableTests

- (void) testFilteredArray
{
    NSArray * testdata = @[
                           @{@"id": @1, @"location": [[CLLocation alloc] initWithLatitude:45 longitude:2]},
                           @{@"id": @2, @"location": [[CLLocation alloc] initWithLatitude:46 longitude:3]},
                           @{@"id": @3, @"location": [[CLLocation alloc] initWithLatitude:47.2 longitude:2.2]},
                           @{@"id": @4, @"location": [[CLLocation alloc] initWithLatitude:47.2 longitude:2]},
                           @{@"id": @5, @"location": [[CLLocation alloc] initWithLatitude:47 longitude:2]},
                           ];
    
    id result = [testdata filteredArrayWithinDistance:100000 fromLocation:[[CLLocation alloc] initWithLatitude:47 longitude:2]];
    
    STAssertEqualObjects([result valueForKeyPath:@"id"], (@[@3, @4, @5]), nil);
}

- (void) testSortedArray
{
    NSArray * testdata = @[
                           @{@"id": @1, @"location": [[CLLocation alloc] initWithLatitude:45 longitude:2]},
                           @{@"id": @2, @"location": [[CLLocation alloc] initWithLatitude:46 longitude:3]},
                           @{@"id": @3, @"location": [[CLLocation alloc] initWithLatitude:47.2 longitude:2.2]},
                           @{@"id": @4, @"location": [[CLLocation alloc] initWithLatitude:47.2 longitude:2]},
                           @{@"id": @5, @"location": [[CLLocation alloc] initWithLatitude:47 longitude:2]},
                           ];
    
    id result = [testdata sortedArrayByDistanceFromLocation:[[CLLocation alloc] initWithLatitude:47 longitude:2]];
    STAssertEqualObjects([result valueForKeyPath:@"id"], (@[@5, @4, @3, @2, @1]), nil);
}

@end

/****************************************************************************/
#pragma mark -

@interface LocalUpdateQueueTests : SenTestCase
@end

@implementation LocalUpdateQueueTests

- (void) testMonitoredGroups
{
    // Prepare a reference points and a group of local points
    LocalUpdateQueue * queue = [LocalUpdateQueue new];
    queue.referenceLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    queue.delayBetweenPointUpdates = .01;
    queue.moniteredGroupsMaximumDistance = 1000000;
    
    id p1 = [@{@"location": [[CLLocation alloc] initWithLatitude:0 longitude:.5]} mutableCopy];
    id p2 = [@{@"location": [[CLLocation alloc] initWithLatitude:0 longitude:-.5]} mutableCopy];
    id g1 = @{@"location" : [[CLLocation alloc] initWithLatitude:0 longitude:1], @"points" : @[p1, p2]};
    
    __block BOOL completed;
    __block int updateCount = 0;
    p1[@"update"] = ^(id obj){ updateCount ++; completed = updateCount==5; };

    // Add our group
    [queue addMonitoredGroup:g1];
    
    // Check it's queued
    STAssertTrue([p1 queuedForUpdate],  nil);
    STAssertTrue([p2 queuedForUpdate],  nil);

    // Check "update" is called repeatedly
    [self waitForCompletion:.1 flag:&completed];
    STAssertTrue(completed,  nil);
    STAssertEquals(updateCount, 5,  nil);

    STAssertTrue([p1 queuedForUpdate],  nil);
    STAssertTrue([p2 queuedForUpdate],  nil);
}

- (void) testOneshotGroups
{
    // Prepare a reference points and a group of local points
    LocalUpdateQueue * queue = [LocalUpdateQueue new];
    queue.referenceLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    queue.delayBetweenPointUpdates = .01;
    queue.moniteredGroupsMaximumDistance = 1000000;
    
    id p1 = [@{@"location": [[CLLocation alloc] initWithLatitude:0 longitude:.5]} mutableCopy];
    id p2 = [@{@"location": [[CLLocation alloc] initWithLatitude:0 longitude:-.5]} mutableCopy];
    id g1 = @{@"location" : [[CLLocation alloc] initWithLatitude:0 longitude:1], @"points" : @[p1, p2]};
    
    __block int updateCount = 0;
    p1[@"update"] = ^(id obj){ updateCount ++; };
    
    // Add our group
    [queue addOneshotGroup:g1];
    
    // Check it's queued
    STAssertTrue([p1 queuedForUpdate],  nil);
    STAssertTrue([p2 queuedForUpdate],  nil);
    
    // Check "update" is called only once
    [self waitForCompletion:.05 flag:NULL];
    
    STAssertEquals(updateCount, 1,  nil);
    
    STAssertFalse([p1 queuedForUpdate],  nil);
    STAssertFalse([p2 queuedForUpdate],  nil);
}

- (void) testMonitoredGroupsDistance
{
    // Prepare a reference points and a group of local points
    LocalUpdateQueue * queue = [LocalUpdateQueue new];
    queue.referenceLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    queue.delayBetweenPointUpdates = .01;
    queue.moniteredGroupsMaximumDistance = 1000000;
    
    id p1 = [@{@"location": [[CLLocation alloc] initWithLatitude:20 longitude:.5]} mutableCopy];
    id g1 = @{@"location" : [[CLLocation alloc] initWithLatitude:0 longitude:1], @"points" : @[p1]};

    id p2 = [@{@"location": [[CLLocation alloc] initWithLatitude:20 longitude:.5]} mutableCopy];
    id g2 = @{@"location" : [[CLLocation alloc] initWithLatitude:10 longitude:1], @"points" : @[p2]};

    // Add our groups
    [queue addMonitoredGroup:g1];
    [queue addMonitoredGroup:g2];
    
    // Check only the points of the near group are queued
    STAssertTrue([p1 queuedForUpdate],  nil);
    STAssertFalse([p2 queuedForUpdate],  nil);
}

- (void) testUpdatedPointsOrder
{
    // Prepare a reference points and a group of local points
    LocalUpdateQueue * queue = [LocalUpdateQueue new];
    queue.referenceLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    queue.delayBetweenPointUpdates = .01;
    queue.moniteredGroupsMaximumDistance = 1000000;
    
    id p1 = [@{@"location": [[CLLocation alloc] initWithLatitude:0 longitude:0]} mutableCopy];
    id g1 = @{@"location" : [[CLLocation alloc] initWithLatitude:0 longitude:0], @"points" : @[p1]};
    
    id p2 = [@{@"location": [[CLLocation alloc] initWithLatitude:0 longitude:0]} mutableCopy];
    id g2 = @{@"location" : [[CLLocation alloc] initWithLatitude:0 longitude:1], @"points" : @[p2]};
    
    // Add our groups
    [queue addMonitoredGroup:g1];
    [queue addMonitoredGroup:g2];

    NSMutableArray * updates = [NSMutableArray new];
    p1[@"update"] = p2[@"update"] = ^(id obj){ [updates addObject:obj]; };

    [self waitForCompletion:.025 flag:NULL]; // Just give it enough time for 2 updates
    STAssertEqualObjects(updates, (@[p1,p2,p1,p2]),nil);
}

@end
