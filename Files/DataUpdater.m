//
//  DataUpdater.m
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "DataUpdater.h"

/****************************************************************************/
#pragma mark -

@interface DataUpdater()
@property NSURL* URL;
@property NSURLConnection * updateConnection;
@property NSMutableData * updateData;
@end

/****************************************************************************/
#pragma mark -

@implementation DataUpdater

/****************************************************************************/
#pragma mark -

- (id) initWithURL:(NSURL*)url_ delegate:(id<DataUpdaterDelegate>) delegate_
{
	self = [super init];
	if (self != nil) 
	{
        self.URL = url_;
        self.delegate = delegate_;
        [self startRequest];
	}
	return self;
}

- (void) startRequest
{
    self.updateConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:self.URL]
                                                          delegate:self];
    [self.delegate updaterDidStartRequest:self];
}

- (void) cancel
{
    [self.updateConnection cancel];
    self.delegate = nil;
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
	else if(response.statusCode==304)
	{
		[self.updateConnection cancel];
		self.updateConnection = nil;
        [self.delegate updaterDidFinishWithNoNewData:self];
	}
	else
    {
		[self.updateConnection cancel];
		self.updateConnection = nil;
        [self.delegate updater:self didFailWithError:[NSError errorWithDomain:@"http" code:response.statusCode userInfo:nil]];
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
    [self.delegate updater:self finishedWithNewData:self.updateData];

	self.updateData = nil;
}

@end

