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
@property NSMutableArray * pointsUpdated;
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
        self.pointsUpdated = [NSMutableArray new];
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

/****************************************************************************/
#pragma mark Groups Lists

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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([LocalUpdateQueue class]))
        // An Update Group has changed its points
        [self buildUpdateQueue];
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
/****************************************************************************/
#pragma mark Data

- (void) buildUpdateQueue
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];

    NSArray * groupsToRefresh = [NSArray new];
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
    
    // queuedForUpdate is used by the UI to display progress indicators
    [[self.pointsInQueue arrayByRemovingObjectsInArray:pointsToUpdate] setValue:@NO forKey:@"queuedForUpdate"];
    [[pointsToUpdate arrayByRemovingObjectsInArray:self.pointsInQueue] setValue:@YES forKey:@"queuedForUpdate"];
    self.pointsInQueue = pointsToUpdate;
    
    if([self.pointsUpdated count]==0)
        [self updateNext];
}

/****************************************************************************/
#pragma mark Update Loop

- (void) updateNext
{
    // Find first point we haven't updated in that loop
    NSArray * pointsNotUpdated = [self.pointsInQueue arrayByRemovingObjectsInArray:self.pointsUpdated];
    if([pointsNotUpdated count])
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

        id<LocalUpdatePoint> point = pointsNotUpdated[0];
        [self.pointsUpdated addObject:point];
        [point updateWithCompletionBlock:^(NSError* error){
            if(error==nil)
            {
                // Call delegate if it's for a oneshot group
                __block id<LocalUpdateGroup> oneshotGroup = nil;
                [self.oneshotGroups enumerateObjectsUsingBlock:^(id<LocalUpdateGroup> group, BOOL *stop) {
                    if([[group pointsToUpdate] containsObject:point])
                    {
                        oneshotGroup = group;
                        *stop = YES;
                    }
                }];
                if(oneshotGroup)
                    [self.delegate updateQueue:self didUpdateOneshotPoint:point ofGroup:oneshotGroup];
            }
            
            // Loop
            [self updateNext];
        }];
    }
    else
    {
        // We've done all the stations in the list !
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        self.pointsUpdated = [NSMutableArray new];
        
        // clear the oneshot groups and restart after a delay
        self.oneshotGroups = [NSMutableSet new];
        [self performSelector:@selector(buildUpdateQueue) withObject:nil afterDelay:self.delayBetweenPointUpdates];
    }
}


@end

/****************************************************************************/
#pragma mark Collections

@implementation NSArray (Locatable)
- (instancetype) filteredArrayWithinDistance:(CLLocationDistance)distance fromLocation:(CLLocation*)location
{
    if(nil==location)
        return [NSArray new];
    return [self filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:
             ^BOOL(id<Locatable> l, NSDictionary *bindings){
                 CLLocationDistance d = [location distanceFromLocation:[l location]];
                 if([l respondsToSelector:@selector(radius)]) d -= [l radius];
                 return d < distance;
             }]];
}

- (instancetype) sortedArrayByDistanceFromLocation:(CLLocation*)location
{
    return [self sortedArrayUsingComparator:
            ^NSComparisonResult(id<Locatable> l1, id<Locatable> l2) {
                CLLocationDistance d1 = [location distanceFromLocation:[l1 location]];
                CLLocationDistance d2 = [location distanceFromLocation:[l2 location]];
                CLLocationDistance r1 = [l1 respondsToSelector:@selector(radius)] ? [l1 radius] : 0.0;
                CLLocationDistance r2 = [l2 respondsToSelector:@selector(radius)] ? [l2 radius] : 0.0;
                
                if(d1>r1 || d2>r2){
                    d1 -= r1;
                    d2 -= r2;
                }
                return d1<d2 ? NSOrderedAscending : d1>d2 ? NSOrderedDescending : NSOrderedSame;
            }];
}
@end
