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
#import "NSMutableArray+Locatable.h"


@interface RadarUpdateQueue () <NSFetchedResultsControllerDelegate>
@property NSFetchedResultsController * frc;
@property (copy) NSArray * radars;
@property (nonatomic) NSArray * stationsToRefresh;
@property NSUInteger currentIndex;
@end

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
        NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:[Radar entityName]];
        request.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:RadarAttributes.identifier ascending:YES] ];
        self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                       managedObjectContext:model.moc
                                                         sectionNameKeyPath:nil cacheName:nil];
        self.frc.delegate = self;
        [self.frc performFetch:NULL];
    }
    return self;
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    for (Radar * radar in self.radars)
        [radar removeObserver:self forKeyPath:@"stationsWithinRadarRegion" context:(__bridge void *)([RadarUpdateQueue class])];

    self.radars = controller.fetchedObjects;

    for (Radar * radar in self.radars)
        [radar addObserver:self forKeyPath:@"stationsWithinRadarRegion" options:0 context:(__bridge void *)([RadarUpdateQueue class])];
    
    [self updateStationsList];
}

- (void) setReferenceLocation:(CLLocation *)referenceLocation
{
    _referenceLocation = referenceLocation;
    [self updateStationsList];
}

- (void) updateStationsList
{
    NSMutableOrderedSet * stationsList = [NSMutableOrderedSet new];
    
    NSMutableArray * sortedRadars = [self.radars mutableCopy];
    [sortedRadars sortByDistanceFromLocation:self.referenceLocation];
    
    for (Radar * radar in sortedRadars) {
        [stationsList addObjectsFromArray:radar.stationsWithinRadarRegion];
    }
    self.stationsToRefresh = [stationsList array];
}

- (void) setStationsToRefresh:(NSArray *)stationsToRefresh
{
    BOOL needsStart = [_stationsToRefresh count]==0;
    [self.stationsToRefresh setValue:@NO forKey:@"needsRefresh"];
    _stationsToRefresh = stationsToRefresh;
    [self.stationsToRefresh setValue:@YES forKey:@"needsRefresh"];
    
    self.currentIndex = 0;

    if(needsStart)
        [self performSelector:@selector(updateNext) withObject:nil afterDelay:.25];
}

- (void) updateNext
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateNext) object:nil];
    
    if(self.currentIndex < [self.stationsToRefresh count])
    {
        Station * stationToRefresh = self.stationsToRefresh[self.currentIndex];
        [stationToRefresh addObserver:self forKeyPath:@"loading" options:0 context:(__bridge void *)([RadarUpdateQueue class])];
        [stationToRefresh refresh];
        self.currentIndex ++;
    }
    else
    {
        self.currentIndex = 0;
        [self performSelector:@selector(updateNext) withObject:nil afterDelay:3];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([RadarUpdateQueue class])) {
        if([object isKindOfClass:[Radar class]])
            [self updateStationsList];
        else if([object isKindOfClass:[Station class]] && [keyPath isEqualToString:@"loading"] && [object loading]==NO)
        {
            [object removeObserver:self forKeyPath:@"loading" context:(__bridge void *)([RadarUpdateQueue class])];
            [self performSelector:@selector(updateNext) withObject:nil afterDelay:.25];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
