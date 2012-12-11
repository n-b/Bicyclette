//
//  LocalUpdateQueue.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 16/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "LocalUpdateQueue.h"
#import "CollectionsAdditions.h"

@interface LocalUpdateQueue () <NSFetchedResultsControllerDelegate>
@property NSMutableSet * monitoredGroups;
@property NSMutableSet * oneshotGroups;
@property NSArray * pointsInQueue;
@property NSObject<LocalUpdatePoint>* pointBeingUpdated;
@property NSUInteger currentIndex;
@end

/****************************************************************************/
#pragma mark -

@implementation LocalUpdateQueue

- (id)init
{
    self = [super init];
    if (self) {
        self.monitoredGroups = [NSMutableSet new];
        self.oneshotGroups = [NSMutableSet new];
    }
    return self;
}

/****************************************************************************/
#pragma mark Setters

- (void) setReferenceLocation:(CLLocation *)referenceLocation
{
    _referenceLocation = referenceLocation;
    [self buildUpdateQueue];
}

- (void) setMonitoringPaused:(BOOL)monitoringPaused_
{
    _monitoringPaused = monitoringPaused_;
    [self buildUpdateQueue];
}

- (void) addGroup:(NSObject<LocalUpdateGroup>*)group toArray:(NSMutableSet*)list
{
    if([list containsObject:group])
        return;
    
    [list addObject:group];
    [group addObserver:self forKeyPath:@"pointsToUpdate" options:0 context:(__bridge void *)([LocalUpdateQueue class])];
    [self buildUpdateQueue];
}

- (void) removeGroup:(NSObject<LocalUpdateGroup>*)group fromArray:(NSMutableSet*)list
{
    if(![list containsObject:group])
        return;
    
    [group removeObserver:self forKeyPath:@"pointsToUpdate"];
    [list removeObject:group];
    [self buildUpdateQueue];
}

- (void) addMonitoredGroup:(NSObject<LocalUpdateGroup>*)group
{
    [self addGroup:group toArray:self.monitoredGroups];
}
- (void) removeMonitoredGroup:(NSObject<LocalUpdateGroup>*)group
{
    [self removeGroup:group fromArray:self.monitoredGroups];
}
- (void) addOneshotGroup:(NSObject<LocalUpdateGroup>*)group
{
    [self addGroup:group toArray:self.oneshotGroups];
}
- (void) removeOneshotGroup:(NSObject<LocalUpdateGroup>*)group
{
    [self removeGroup:group fromArray:self.oneshotGroups];
}

/****************************************************************************/
#pragma mark Data

- (void) buildUpdateQueue
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];

    NSArray * groupsToRefresh;
    if(!self.monitoringPaused)
    {
        // if the app is active, update the monitored groups
        NSArray * sortedGroups = [self.monitoredGroups allObjects];
        sortedGroups = [sortedGroups filteredArrayWithinDistance:self.moniteredGroupsMaximumDistance fromLocation:self.referenceLocation];
        sortedGroups = [sortedGroups sortedArrayByDistanceFromLocation:self.referenceLocation];
        groupsToRefresh = sortedGroups;
    }

    groupsToRefresh = [groupsToRefresh arrayByAddingObjectsFromArray:[self.oneshotGroups allObjects]];
    
    // make the list
    NSMutableOrderedSet * pointsSet = [NSMutableOrderedSet new]; // use an orderedset to make sure each station is added only once
    for (id<LocalUpdateGroup> group in groupsToRefresh)
        [pointsSet addObjectsFromArray:[group pointsToUpdate]];
    NSArray * pointsToUpdate = [pointsSet array];
    
    // if it's a different list, restart from beginning
    if( ! [self.pointsInQueue isEqual:pointsToUpdate])
    {
        // queuedForUpdate is used by the UI to display progress indicators
        [self.pointsInQueue setValue:@(NO) forKey:@"queuedForUpdate"];
        self.pointsInQueue = pointsToUpdate;
        [self.pointsInQueue setValue:@(YES) forKey:@"queuedForUpdate"];

        self.currentIndex = 0;
    }
    
    if(self.pointBeingUpdated==nil)
    {
        [self updateNext];
    }
}

/****************************************************************************/
#pragma mark Update Loop

- (void) updateNext
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    
    if(self.currentIndex < [self.pointsInQueue count])
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        // refresh next station in the list
        self.pointBeingUpdated = self.pointsInQueue[self.currentIndex];
        self.currentIndex ++;
        [self.pointBeingUpdated updateWithCompletionBlock:^{
            __block id<LocalUpdateGroup> groupOfPoint = nil;
            [self.oneshotGroups enumerateObjectsUsingBlock:^(id<LocalUpdateGroup> group, BOOL *stop) {
                if([[group pointsToUpdate] containsObject:self.pointBeingUpdated])
                {
                    groupOfPoint = group;
                    *stop = YES;
                }
            }];
            if(groupOfPoint)
                [self.delegate updateQueue:self didUpdateOneshotPoint:self.pointBeingUpdated ofGroup:groupOfPoint];
            [self updateNext];
        }];
    }
    else
    {
        // We've done all the stations in the list !
        self.currentIndex = 0;
        self.pointBeingUpdated = nil;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        // clear the summary flag : we only want it once.
        self.oneshotGroups = [NSMutableSet new];
        
        // after a delay, compute new list, and restart.
        [self performSelector:@selector(buildUpdateQueue) withObject:nil afterDelay:self.delayBetweenPointUpdates];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([LocalUpdateQueue class])) {
        if([object conformsToProtocol:@protocol(LocalUpdateGroup)])
        {
            // A radar has changed : update the list of stations
            if([keyPath isEqualToString:@"pointsToUpdate"])
                [self buildUpdateQueue];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

/****************************************************************************/
#pragma mark Collections

@implementation NSArray (Locatable)
- (instancetype) filteredArrayWithinDistance:(CLLocationDistance)distance fromLocation:(CLLocation*)location
{
    return [self filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:
             ^BOOL(id<Locatable> locatable, NSDictionary *bindings){
                 return location && [location distanceFromLocation:locatable.location] < distance;
             }]];
}

- (instancetype) sortedArrayByDistanceFromLocation:(CLLocation*)location
{
    return [self sortedArrayUsingComparator:
            ^NSComparisonResult(id<Locatable> l1, id<Locatable> l2) {
                CLLocationDistance d1 = [location distanceFromLocation:l1.location];
                CLLocationDistance d2 = [location distanceFromLocation:l2.location];
                return d1<d2 ? NSOrderedAscending : d1>d2 ? NSOrderedDescending : NSOrderedSame;
            }];
}
@end
