//
//  RadarUpdateQueue.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 16/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "LocalUpdateQueue.h"
#import "BicycletteCity.h"
#import "NSMutableArray+Locatable.h"
#import "CollectionsAdditions.h"

@interface LocalUpdateQueue () <NSFetchedResultsControllerDelegate>
@property NSMutableSet * updateGroups;
@property (nonatomic) NSArray * updatePoints;
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

        // observe app state changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStationsList) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStationsList) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStationsList) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStationsList) name:UIApplicationWillResignActiveNotification object:nil];
        
        self.updateGroups = [NSMutableSet new];
    }
    return self;
}

/****************************************************************************/
#pragma mark -

- (void) addGroup:(NSObject<LocalUpdateGroup>*)group
{
    if(![self.updateGroups containsObject:group])
    {
        [group addObserver:self forKeyPath:@"updatePoints" options:0 context:(__bridge void *)([LocalUpdateQueue class])];
        [self.updateGroups addObject:group];
        [self updateStationsList];
    }
}

- (void) removeGroup:(NSObject<LocalUpdateGroup>*)group
{
    if(![self.updateGroups containsObject:group])
    {
        [group removeObserver:self forKeyPath:@"updatePoints"];
        [self.updateGroups removeObject:group];
        [self updateStationsList];
    }
}

- (void) setGroups:(NSSet *)groups_
{
    for (NSObject<LocalUpdateGroup>* updateGroup in self.updateGroups)
        [self removeGroup:updateGroup];
    
    self.groups = [groups_ mutableCopy];
    
    for (NSObject<LocalUpdateGroup>* updateGroup in self.updateGroups)
        [self addGroup:updateGroup];
}

- (void) setReferenceLocation:(CLLocation *)referenceLocation
{
    _referenceLocation = referenceLocation;
    [self updateStationsList];
}

- (void) updateStationsList
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];

    BOOL isAppActive = [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
        
    NSArray * groupsToRefresh;
    CLLocationDistance refreshDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"MaxRefreshDistance"];
    if(isAppActive)
    {
        // if the app is active, it's simply the stations of the radars,
        // within a limit, from the nearest.
        NSMutableArray * sortedGroups = [[self.updateGroups allObjects] mutableCopy];
        [sortedGroups filterWithinDistance:refreshDistance fromLocation:self.referenceLocation];
        [sortedGroups sortByDistanceFromLocation:self.referenceLocation];
        groupsToRefresh = sortedGroups;
    }
    else
    {
        // if the app is inactive, the referenceLocation is unused, we just use the summary flag
        groupsToRefresh = [[self.updateGroups filteredSetWithValue:@(YES) forKeyPath:@"wantsSummary"] allObjects];
    }
        
    // make the list
    NSMutableOrderedSet * pointsList = [NSMutableOrderedSet new]; // use an orderedset to make sure each station is added only once
    for (id<LocalUpdateGroup> group in groupsToRefresh)
        [pointsList addObjectsFromArray:group.updatePoints];
    self.updatePoints = [pointsList array];
}

- (void) setUpdatePoints:(NSArray *)updatePoints
{
    // if it's a different list, restart from beginning
    if( ! [_updatePoints isEqual:updatePoints])
        self.currentIndex = 0;

    // isInRefreshQueue is used by the UI to display progress indicators
    [self.updatePoints setValue:@(NO) forKey:@"isInRefreshQueue"];
    _updatePoints = [updatePoints copy];
    [self.updatePoints setValue:@(YES) forKey:@"isInRefreshQueue"];
    
    if(self.pointBeingUpdated==nil)
        [self updateNext];
}

- (void) updateNext
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    
    if(self.currentIndex < [self.updatePoints count])
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        // refresh next station in the list
        //
        // the pointBeingUpdated (strong) property is very important
        // because it prevents the object from being turned into a fault by CoreData,
        // which would render our KVO invalid. Not much fun.
        self.pointBeingUpdated = self.updatePoints[self.currentIndex];
        [self.pointBeingUpdated addObserver:self forKeyPath:@"loading" options:0 context:(__bridge void *)([LocalUpdateQueue class])];
        [self.pointBeingUpdated update];
        self.currentIndex ++;
    }
    else
    {
        // We've done all the stations in the list !
        self.currentIndex = 0;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        // clear the summary flag : we only want it once.
//        [self.updateGroups setValue:@(NO) forKey:@"wantsSummary"];
        
        // after a delay, compute new list, and restart. (only if app is active)
        if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
        {
            NSTimeInterval delay = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DataUpdaterDelayBetweenQueues"];
            [self performSelector:@selector(updateStationsList) withObject:nil afterDelay:delay];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([LocalUpdateQueue class])) {
        Protocol * p = @protocol(LocalUpdatePoint);
        if([object conformsToProtocol:@protocol(LocalUpdateGroup)])
        {
            // A radar has changed : update the list of stations
            if([keyPath isEqualToString:@"updatePoints"])
                [self updateStationsList];
            else if([keyPath isEqualToString:@"wantsSummary"] && [object wantsSummary])
                // only update if wantsSummary is YES. We do not want to update when the flag is cleared.
                // (if it's cleared because leaving a zone, the summary display will be ignored anyway)
                [self updateStationsList];
        }
        else if([[object class] conformsToProtocol:p] && [keyPath isEqualToString:@"loading"] && [object loading]==NO)
        {
            // The station being refreshed has finished (maybe on error, but it's no more "loading").
            NSAssert(object == self.pointBeingUpdated,@"error : wrong station being refreshed");
            [self.pointBeingUpdated removeObserver:self forKeyPath:@"loading" context:(__bridge void *)([LocalUpdateQueue class])];
            self.pointBeingUpdated = nil;
            [self updateNext];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

