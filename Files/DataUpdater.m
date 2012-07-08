//
//  DataUpdater.m
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Visuamobile. All rights reserved.
//

#import "DataUpdater.h"
#import "NSData+SHA1.h"

@interface DataUpdater()
@property (nonatomic, strong) NSURLConnection * updateConnection;
@property (nonatomic, strong) NSMutableData * updateData;

@end

/****************************************************************************/
#pragma mark -

@implementation DataUpdater
@synthesize updateConnection, updateData;
@synthesize delegate;

/****************************************************************************/
#pragma mark -

+ (id) updaterWithDelegate:(id<DataUpdaterDelegate>) delegate_
{
    return [[self alloc] initWithDelegate:delegate_];
}

+ (NSMutableArray*) queuedUpdaters
{
    static NSMutableArray * s_queued;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ s_queued = [NSMutableArray new]; });
    return s_queued;
}

+ (NSMutableArray*) activeUpdaters
{
    static NSMutableArray *s_active;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ s_active = [NSMutableArray new]; });
    return s_active;
}

+ (void) startUpdater:(DataUpdater*)updater
{
    @synchronized(self)
    {
        NSAssert(![[self queuedUpdaters] containsObject:updater],@"the same updater can't be reused");
        
        if([[self activeUpdaters] containsObject:updater])
            [[self activeUpdaters] removeObject:updater];
        else
            [[self queuedUpdaters] addObject:updater];
        
        while([[self queuedUpdaters] count] && [[self activeUpdaters] count] < (NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:@"DataUpdaterMaxConcurrentRequests"] )
        {
            DataUpdater * updaterStarted = [[self queuedUpdaters] objectAtIndex:0];
            [[self activeUpdaters] addObject:updaterStarted];
            [[self queuedUpdaters] removeObjectAtIndex:0];

            double delayInSeconds = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DataUpdaterDelayBetweenRequests"];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [updaterStarted startRequest];
            });
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = [[self activeUpdaters] count]>0;
    }
}

+ (void) cancelUpdater:(DataUpdater*)updater
{
    @synchronized(self)
    {
        NSAssert([[self queuedUpdaters] containsObject:updater], @"trying to remove an updater that was not queued");
        [[self queuedUpdaters] removeObject:updater];
    }
}

- (id) initWithDelegate:(id<DataUpdaterDelegate>) delegate_
{
	self = [super init];
	if (self != nil) 
	{
        self.delegate = delegate_;
        BOOL needUpdate = YES;
		// Find if I need to update
        if (([self.delegate respondsToSelector:@selector(dataDateForUpdater:)] && [self.delegate respondsToSelector:@selector(refreshIntervalForUpdater:)]) 
            && ! [[NSUserDefaults standardUserDefaults] boolForKey:@"DebugRemoveStore"])
        {
            NSDate * createDate = [self.delegate dataDateForUpdater:self];
            needUpdate = (nil==createDate || [[NSDate date] timeIntervalSinceDate:createDate] > [self.delegate refreshIntervalForUpdater:self]);
        }
        
		if(needUpdate)
        {
            [self.delegate updaterDidBegin:self];
            [[self class] startUpdater:self];
        }
        else
        {
            // Do not even start
            return nil;
        }
	}
	return self;
}

- (void) startRequest
{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[self.delegate urlForUpdater:self]];
    [request setValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
    self.updateConnection = [NSURLConnection connectionWithRequest:request
                                                          delegate:self];
    [self.delegate updaterDidStartRequest:self];
}

- (void) cancel
{
    if(self.updateConnection)
    {
        [self.updateConnection cancel];
        [[self class] startUpdater:self];
    }
    else
        [[self class] cancelUpdater:self];
}

- (void) dealloc
{
	[self.updateConnection cancel];
}

/****************************************************************************/
#pragma mark URL request 

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	if(response.statusCode==200)
		self.updateData = [NSMutableData data];
	else
	{
		[self.updateConnection cancel];
		self.updateConnection = nil;

        [[self class] startUpdater:self];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.updateData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self.updateConnection cancel];
	self.updateConnection = nil;
	self.updateData = nil;
    [self.delegate updater:self didFailWithError:error];

    [[self class] startUpdater:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	self.updateConnection = nil;
    BOOL notifyDelegate = YES;
    if([self.delegate respondsToSelector:@selector(knownDataSha1ForUpdater:)])
    {
        NSString * oldSha1 = [self.delegate knownDataSha1ForUpdater:self];
        NSString * newSha1 = [self.updateData sha1DigestString];
        if([oldSha1 isEqualToString:newSha1] && ! [[NSUserDefaults standardUserDefaults] boolForKey:@"DebugRemoveStore"])
        {
            notifyDelegate = NO;
            NSLog(@"No need to rebuild database, the data actually hasn't changed.");
        }
        else if([self.delegate respondsToSelector:@selector(setUpdater:knownDataSha1:)])
            [self.delegate setUpdater:self knownDataSha1:newSha1];
    }

    if([self.delegate respondsToSelector:@selector(setUpdater:dataDate:)])
        [self.delegate setUpdater:self dataDate:[NSDate date]];

    if(notifyDelegate)
		[self.delegate updater:self finishedWithNewData:self.updateData];
    else
        [self.delegate updaterDidFinishWithNoNewData:self];

	self.updateData = nil;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^(void){
        [[self class] startUpdater:self];
    });
}

@end
