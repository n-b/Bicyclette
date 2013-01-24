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
@property NSMutableArray * monitoredGroups;
@property NSMutableArray * oneshotGroups;
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
        self.monitoredGroups = [NSMutableArray new];
        self.oneshotGroups = [NSMutableArray new];
        self.pointsUpdated = [NSMutableArray new];
    }
    return self;
}

/****************************************************************************/
#pragma mark Setters

- (void) setReferenceLocation:(CLLocation *)referenceLocation
{
    [self setReferenceLocation:referenceLocation andStartIfNecessary:YES];
}

- (void) setReferenceLocation:(CLLocation *)referenceLocation andStartIfNecessary:(BOOL)startIfNecessary_
{
    _referenceLocation = referenceLocation;
    [self buildUpdateQueueAndStartIfNecessary:startIfNecessary_];
}

- (void) setMonitoringPaused:(BOOL)monitoringPaused_
{
    _monitoringPaused = monitoringPaused_;
    [self buildUpdateQueue];
}

/****************************************************************************/
#pragma mark Groups Lists

- (void) addGroup:(NSObject<LocalUpdateGroup>*)group toArray:(NSMutableArray*)list
{
    if([list containsObject:group])
        return;
    
    [list addObject:group];
    [group addObserver:self forKeyPath:@"pointsToUpdate" options:0 context:(__bridge void *)([LocalUpdateQueue class])];
    [self buildUpdateQueue];
}

- (void) removeGroup:(NSObject<LocalUpdateGroup>*)group fromArray:(NSMutableArray*)list
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
        [self buildUpdateQueueAndStartIfNecessary:NO];
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
/****************************************************************************/
#pragma mark Data

- (void) buildUpdateQueue
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [self buildUpdateQueueAndStartIfNecessary:YES];
}

- (void) buildUpdateQueueAndStartIfNecessary:(BOOL)startIfNecessary_
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];

    NSArray * groupsToRefresh = [NSArray new];
    if(!self.monitoringPaused)
    {
        // if the app is active, update the monitored groups
        NSArray * sortedGroups = self.monitoredGroups;
        sortedGroups = [sortedGroups sortedArrayByDistanceFromLocation:self.referenceLocation];
        groupsToRefresh = sortedGroups;
    }

    groupsToRefresh = [groupsToRefresh arrayByAddingObjectsFromArray:self.oneshotGroups];
    
    // make the list
    NSMutableOrderedSet * pointsSet = [NSMutableOrderedSet new]; // use an orderedset to make sure each station is added only once
    for (id<LocalUpdateGroup> group in groupsToRefresh)
        [pointsSet addObjectsFromArray:[group pointsToUpdate]];
    NSArray * pointsToUpdate = [pointsSet array];
    
    // queuedForUpdate is used by the UI to display progress indicators
    for (id<LocalUpdatePoint>point in [self.pointsInQueue arrayByRemovingObjectsInArray:pointsToUpdate]) {
        if([point respondsToSelector:@selector(setQueuedForUpdate:)])
            [point setQueuedForUpdate:NO];
    }
    for (id<LocalUpdatePoint>point in [pointsToUpdate arrayByRemovingObjectsInArray:self.pointsInQueue]) {
        if([point respondsToSelector:@selector(setQueuedForUpdate:)])
            [point setQueuedForUpdate:YES];
    }
    self.pointsInQueue = pointsToUpdate;
    
    if(startIfNecessary_ && [self.pointsUpdated count]==0)
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
                [self.oneshotGroups enumerateObjectsUsingBlock:^(id<LocalUpdateGroup> group, NSUInteger idx, BOOL *stop) {
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
        self.oneshotGroups = [NSMutableArray new];
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
                return d1<d2 ? NSOrderedAscending : d1>d2 ? NSOrderedDescending : NSOrderedSame;
            }];
}

- (id<Locatable>) nearestLocatableFrom:(CLLocation*)location
{
    __block id<Locatable> result = nil;
    [self enumerateObjectsUsingBlock:^(id<Locatable> obj, NSUInteger idx, BOOL *stop) {
        if(!result)
        {
            result = obj;
            return;
        }
        
        CLLocationDistance d1 = [location distanceFromLocation:[result location]];
        CLLocationDistance d2 = [location distanceFromLocation:[obj location]];
        
        // The radius is used to weigh the distance, in order to favor larger objects.
        //
        // The idea is that a big object should be considered "nearer" than a very small object.
        // If location is 1500m from from a big object (r=1000m), and 500m from a small object (r=10m),
        // The "distances" are : 1.5 to the big object, and 50 to the small object.
        //
        // Basically, I want Vélib to be more important than Cristolib.
        if([result respondsToSelector:@selector(radius)] && [obj respondsToSelector:@selector(radius)])
        {
            d1 /= [result radius];
            d2 /= [obj radius];
        }

        if(d2<d1)
            result = obj;
    }];
    
    return result;
}
@end
