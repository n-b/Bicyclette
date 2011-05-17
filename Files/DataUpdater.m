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
@property (nonatomic, retain) NSURLConnection * updateConnection;
@property (nonatomic, retain) NSMutableData * updateData;
- (void) updateXML;

@property (nonatomic, copy) NSString* knownDataSHA1;
@property (nonatomic, copy) NSDate* dataDate;

- (NSTimeInterval) refreshInterval;

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
    return [[[self alloc] initWithDelegate:delegate_] autorelease];
}

- (id) initWithDelegate:(id<DataUpdaterDelegate>) delegate_
{
	self = [super init];
	if (self != nil) 
	{
        self.delegate = delegate_;
        
		// Find if I need to update
		NSDate * createDate = self.dataDate;
		BOOL needUpdate = (nil==createDate || [[NSDate date] timeIntervalSinceDate:createDate] > self.refreshInterval);
		if(needUpdate)
			[self performSelector:@selector(updateXML) withObject:nil afterDelay:0];
	}
	return self;
}

- (void) dealloc
{
	[self.updateConnection cancel];
	self.updateConnection = nil;
	self.updateData = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark URL request 

- (void) updateXML
{
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[self.delegate urlForUpdater:self]];
	self.updateConnection = [NSURLConnection connectionWithRequest:request
														  delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	if(response.statusCode==200)
		self.updateData = [NSMutableData data];
	else
	{
		[self.updateConnection cancel];
		self.updateConnection = nil;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.updateData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"download failed %@",error);
	[self.updateConnection cancel];
	self.updateConnection = nil;
	self.updateData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	self.updateConnection = nil;
    NSString * oldSha1 = self.knownDataSHA1;
    NSString * newSha1 = [self.updateData sha1DigestString];
    if([oldSha1 isEqualToString:newSha1])
    {
        NSLog(@"No need to rebuild database, the data actually hasn't changed.");
    }
    else
    {
		[self.delegate updater:self finishedReceivingData:self.updateData];
        self.knownDataSHA1 = newSha1;
    }
    self.dataDate = [NSDate date];
	self.updateData = nil;
}

/****************************************************************************/
#pragma mark Preference Keys

- (NSTimeInterval) refreshInterval
{
    if ([self.delegate respondsToSelector:@selector(refreshIntervalForUpdater:)]) {
        return [self.delegate refreshIntervalForUpdater:self];
    }
    else
        return [[NSUserDefaults standardUserDefaults] doubleForKey:@"DatabaseReloadInterval"];
}

- (NSString *) knownDataSHA1
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"Database_XML_SHA1"];
}

- (void) setKnownDataSHA1:(NSString*)newSha1
{
    [[NSUserDefaults standardUserDefaults] setObject:newSha1 forKey:@"Database_XML_SHA1"];
}

- (NSString *) dataDate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"DatabaseCreateDate"];
}

- (void) setDataDate:(NSDate*) date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"DatabaseCreateDate"];
}

/****************************************************************************/
#pragma mark status

+ (NSSet*) keyPathsForValuesAffectingDownloadingUpdate
{
	return [NSSet setWithObject:@"updateConnection"];
}

- (BOOL) downloadingUpdate
{
	return self.updateConnection!=nil;
}

@end
