//
//  RadarUpdateQueue.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 16/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "RadarUpdateQueue.h"
#import "VelibModel.h"
#import "Radar.h"
#import "Station.h"
#import "NSMutableArray+Locatable.h"
#import "NSArrayAdditions.h"

@interface RadarUpdateQueue () <NSFetchedResultsControllerDelegate>
@property NSFetchedResultsController * frc;
@property (copy) NSArray * radars; // copy
@property (nonatomic) NSArray * stationsToRefresh;
@property Station * stationBeingRefreshed;
@property NSUInteger currentIndex;
@end

/****************************************************************************/
#pragma mark -

@implementation RadarUpdateQueue

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return self;
}

- (id)initWithModel:(VelibModel*)model
{
    self = [super init];
    if (self) {

        // observe app state changes
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                          object:nil queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) { [self updateStationsList]; }];

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) { [self updateStationsList]; }];

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                          object:nil queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) { [self updateStationsList]; }];

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                          object:nil queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) { [self updateStationsList]; }];


        // observe all radars
        NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:[Radar entityName]];
        request.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:RadarAttributes.identifier ascending:YES] ]; // frc *needs* a sort descriptor
        self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                       managedObjectContext:model.moc
                                                         sectionNameKeyPath:nil cacheName:nil];
        self.frc.delegate = self;
        [self.frc performFetch:NULL];
    }
    return self;
}

/****************************************************************************/
#pragma mark -

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    for (Radar * radar in self.radars)
    {
        [radar removeObserver:self forKeyPath:@"stationsWithinRadarRegion" context:(__bridge void *)([RadarUpdateQueue class])];
        [radar removeObserver:self forKeyPath:@"wantsSummary" context:(__bridge void *)([RadarUpdateQueue class])];
    }

    // radars has "copy" semantics. Otherwise, that would be the same array object.
    // (which would crash above in removeObserver)
    self.radars = controller.fetchedObjects;

    for (Radar * radar in self.radars)
    {
        [radar addObserver:self forKeyPath:@"stationsWithinRadarRegion" options:0 context:(__bridge void *)([RadarUpdateQueue class])];
        [radar addObserver:self forKeyPath:@"wantsSummary" options:0 context:(__bridge void *)([RadarUpdateQueue class])];
    }
    
    [self updateStationsList];
}

- (void) setReferenceLocation:(CLLocation *)referenceLocation
{
    _referenceLocation = referenceLocation;
    [self updateStationsList];
}

- (void) updateStationsList
{
    BOOL isAppActive = [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
    
    // Compute the list of stations to refresh continuously
    NSMutableOrderedSet * stationsList = [NSMutableOrderedSet new]; // use an orderedset to make sure each station is added only once
    
    NSArray * radarsToRefresh;
    CLLocationDistance refreshDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"MaxRefreshDistance"];
    if(isAppActive)
    {
        // if the app is active, it's simply the stations of the radars,
        // within a limit, from the nearest.
        NSMutableArray * sortedRadars = [self.radars mutableCopy];
        [sortedRadars filterWithinDistance:refreshDistance fromLocation:self.referenceLocation];
        [sortedRadars sortByDistanceFromLocation:self.referenceLocation];
        radarsToRefresh = sortedRadars;
    }
    else
    {
        // if the app is inactive, the referenceLocation is unused, we just use the summary flag
        radarsToRefresh = [self.radars filteredArrayWithValue:@(YES) forKey:@"wantsSummary"];
    }
        
    // make the list
    for (Radar * radar in radarsToRefresh)
        [stationsList addObjectsFromArray:radar.stationsWithinRadarRegion];
    self.stationsToRefresh = [stationsList array];
}

- (void) setStationsToRefresh:(NSArray *)stationsToRefresh
{
    // isInRefreshQueue is used by the UI to display progress indicators
    [self.stationsToRefresh setValue:@(NO) forKey:@"isInRefreshQueue"];
    _stationsToRefresh = stationsToRefresh;
    [self.stationsToRefresh setValue:@(YES) forKey:@"isInRefreshQueue"];
    
    self.currentIndex = 0;

    if(self.stationBeingRefreshed==nil)
        [self performSelector:@selector(updateNext) withObject:nil afterDelay:.25];
}

- (void) updateNext
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateNext) object:nil];
    
    if(self.currentIndex < [self.stationsToRefresh count])
    {
        // refresh next station in the list
        //
        // the stationBeingRefreshed (strong) property is very important
        // because it prevents the object from being turned into a fault by CoreData,
        // which would render our KVO invalid. Not much fun.
        self.stationBeingRefreshed = self.stationsToRefresh[self.currentIndex];
        [self.stationBeingRefreshed addObserver:self forKeyPath:@"loading" options:0 context:(__bridge void *)([RadarUpdateQueue class])];
        [self.stationBeingRefreshed refresh];
        self.currentIndex ++;
    }
    else
    {
        // We've done all the stations in the list !
        self.currentIndex = 0;

        // clear the summary flag : we only want it once.
        [self.radars setValue:@(NO) forKey:@"wantsSummary"];
        
        // after a delay, compute new list, and restart. (only if app is active)
        if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
            [self performSelector:@selector(updateStationsList) withObject:nil afterDelay:3];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([RadarUpdateQueue class])) {
        if([object isKindOfClass:[Radar class]])
        {
            // A radar has changed : update the list of stations
            if([keyPath isEqualToString:@"stationsWithinRadarRegion"])
                [self updateStationsList];
            else if([keyPath isEqualToString:@"wantsSummary"] && [object wantsSummary])
                // only update if wantsSummary is YES. We do not want to update when the flag is cleared.
                // (if it's cleared because leaving a zone, the summary display will be ignored anyway)
                [self updateStationsList];
        }
        else if([object isKindOfClass:[Station class]] && [keyPath isEqualToString:@"loading"] && [object loading]==NO)
        {
            // The station being refreshed has finished (maybe on error, but it's no more "loading").
            NSAssert(object == self.stationBeingRefreshed,@"error : wrong station being refreshed");
            [self.stationBeingRefreshed removeObserver:self forKeyPath:@"loading" context:(__bridge void *)([RadarUpdateQueue class])];
            self.stationBeingRefreshed = nil;
            [self performSelector:@selector(updateNext) withObject:nil afterDelay:.05];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
