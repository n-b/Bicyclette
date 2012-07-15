//
//  UpdaterQueue.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 16/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "UpdaterQueue.h"
#import "DataUpdater.h"

@implementation UpdaterQueue
{
    NSMutableArray * _queuedUpdaters, * _activeUpdaters;
}

+ (id)queueWithName:(NSString*)name
{
    static NSMutableDictionary * s_queues;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_queues = [NSMutableDictionary new];
    });
    @synchronized(self)
    {
        UpdaterQueue * q = [s_queues objectForKey:name];
        if(q==nil)
        {
            q = [UpdaterQueue new];
            [s_queues setObject:q forKey:name];
        }
        return q;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        _queuedUpdaters = [NSMutableArray new];
        _activeUpdaters = [NSMutableArray new];
    }
    return self;
}

- (void) startUpdater:(DataUpdater*)updater
{
    @synchronized(self)
    {
        NSAssert(![_queuedUpdaters containsObject:updater],@"the same updater can't be reused");
        
        if([_activeUpdaters containsObject:updater])
            [_activeUpdaters removeObject:updater];
        else
            [_queuedUpdaters addObject:updater];
        
        while([_queuedUpdaters count] && [_activeUpdaters count] < (NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:@"DataUpdaterMaxConcurrentRequests"] )
        {
            DataUpdater * updaterStarted = [_queuedUpdaters objectAtIndex:0];
            [_activeUpdaters addObject:updaterStarted];
            [_queuedUpdaters removeObjectAtIndex:0];
            
            double delayInSeconds = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DataUpdaterDelayBetweenRequests"];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [updaterStarted startRequest];
            });
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = [_activeUpdaters count]>0;
    }
}

- (void) cancelUpdater:(DataUpdater*)updater
{
    @synchronized(self)
    {
        NSAssert([_queuedUpdaters containsObject:updater], @"trying to remove an updater that was not queued");
        [_queuedUpdaters removeObject:updater];
    }
}

@end
