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
@property NSMutableArray * urls;
@property NSMutableDictionary * chunks;

@property NSURLConnection * updateConnection;
@property NSMutableData * updateData;
@end

/****************************************************************************/
#pragma mark -

@implementation DataUpdater

/****************************************************************************/
#pragma mark -

- (id) initWithURLStrings:(NSMutableArray*)urlStrings_ delegate:(id<DataUpdaterDelegate>)delegate_
{
	self = [super init];
	if (self != nil) 
	{
        NSAssert([urlStrings_ count],@"There must be at least 1 url");
        
        self.delegate = delegate_;

        self.urls = [NSMutableArray new];
        for (NSString * urlString in urlStrings_) {
            [self.urls addObject:[NSURL URLWithString:urlString]];
        }
        self.chunks = [NSMutableDictionary new];
        
        [self startNextRequest];
	}
	return self;
}

- (void) startNextRequest
{
    self.updateConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:self.urls[0]]
                                                          delegate:self];
}

- (void) cancel
{
    [self.updateConnection cancel];
    self.updateData = nil;
    self.urls = nil;
    self.chunks = nil;
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
        [self.delegate updaterDidFinishWithNoNewData:self];
        [self cancel];
	}
	else
    {
        [self.delegate updater:self didFailWithError:[NSError errorWithDomain:@"http" code:response.statusCode userInfo:nil]];
        [self cancel];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.updateData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate updater:self didFailWithError:error];
    [self cancel];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.chunks setObject:self.updateData forKey:[self.urls[0] absoluteString]];
    [self.urls removeObjectAtIndex:0];
    self.updateConnection = nil;
	self.updateData = nil;
    
    if([self.urls count])
        [self startNextRequest];
    else
        [self.delegate updater:self finishedWithNewDataChunks:self.chunks];
}

@end

