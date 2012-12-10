//
//  DataUpdater.m
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "DataUpdater.h"
#import "NSData+SHA1.h"

/****************************************************************************/
#pragma mark -

@interface DataUpdater()
@property NSURLConnection * updateConnection;
@property NSMutableData * updateData;
@end

/****************************************************************************/
#pragma mark -

@implementation DataUpdater

/****************************************************************************/
#pragma mark -

- (id) initWithDelegate:(id<DataUpdaterDelegate>) delegate_
{
	self = [super init];
	if (self != nil) 
	{
        self.delegate = delegate_;
        BOOL needUpdate = YES;
		// Find if I need to update
        if ([self.delegate respondsToSelector:@selector(dataDateForUpdater:)]
             && [self.delegate respondsToSelector:@selector(refreshIntervalForUpdater:)])
        {
            NSDate * createDate = [self.delegate dataDateForUpdater:self];
            needUpdate = (nil==createDate || [[NSDate date] timeIntervalSinceDate:createDate] > [self.delegate refreshIntervalForUpdater:self]);
        }

		if(needUpdate)
        {
            [self startRequest];
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
        [self.updateConnection cancel];
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
        [self.delegate updaterDidFinishWithNoNewData:self];
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
}

@end

