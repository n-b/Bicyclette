//
//  RootViewController.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "RootViewController.h"
#import "StationCell.h"

@interface RootViewController() <UISearchBarDelegate>
@property (nonatomic,retain) NSArray * stationsArray;
@property (nonatomic,retain) NSMutableDictionary * stationsDictionary;
@property (nonatomic,retain) NSMutableSet * currentRequests;
@property (nonatomic,retain) NSMutableArray * favoritesArray;
@property (nonatomic,readonly) UITableView * tableView;

- (void) requestInfo:(NSDictionary *) requestDict;
- (void) setStationInfo:(NSDictionary *) dictionary;
@end


@implementation RootViewController
@synthesize stationsArray, stationsDictionary, currentRequests, favoritesArray;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.stationsArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"velib-all" ofType:@"plist"]];
	self.stationsDictionary = [NSMutableDictionary dictionary];
	self.currentRequests = [NSMutableSet set];
	self.favoritesArray = [NSMutableArray array];
}

- (UITableView*) tableView
{
	return (UITableView*)self.view;
}


- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.tableView.contentOffset = CGPointMake(0,44);
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self performSelector:@selector(sendRequests) withObject:nil afterDelay:.5 inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [stationsArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	StationCell * cell = [StationCell reusableCellForTable:tableView];
	NSDictionary * station = [stationsArray objectAtIndex:[indexPath row]];
	cell.station = station;
	cell.stationInfo = [stationsDictionary objectForKey:[station objectForKey:@"name"]];
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.favoritesArray addObject:[[self.stationsArray objectAtIndex:[indexPath row]] objectForKey:@"name"]];
	[self performSelector:@selector(deselectRowAtIndexPath:) withObject:indexPath afterDelay:.5];
}
- (void) deselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	shouldCancel = YES;
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(sendRequests) withObject:nil afterDelay:.5 inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (void) sendRequests
{
	NSLog(@"send requests");
	shouldCancel = NO;
	for (NSIndexPath * indexPath in [self.tableView indexPathsForVisibleRows]) {
		NSDictionary * station = [stationsArray objectAtIndex:[indexPath row]];
		NSString * stationName = [station objectForKey:@"name"];
		if([self.currentRequests containsObject:stationName])
		{
			NSLog(@"skipping (already requesting) %@",stationName);
			continue;
		}
		NSDictionary * stationInfo = [stationsDictionary objectForKey:stationName];
		if(stationInfo && [[NSDate date] timeIntervalSinceDate:[stationInfo objectForKey:@"date"]] < 30)
		{
			NSLog(@"skipping (recent status) %@",stationName);
			continue;
		}
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[self.currentRequests addObject:stationName];
		[self performSelectorInBackground:@selector(requestInfo:) 
							   withObject:[NSDictionary dictionaryWithObjectsAndKeys:
										   indexPath,@"indexPath",
										   stationName,@"name",
										   nil]];
	}
}


- (void) requestInfo:(NSDictionary *) requestDict
{
#define veliburl @"http://www.velib.paris.fr/service/stationdetails/"
	NSAutoreleasePool * pool = [NSAutoreleasePool new];
	NSDictionary * stationDict = nil;
	if(shouldCancel)
	{
		NSLog(@"Cancelling! %@",[requestDict objectForKey:@"name"]);
	}
	else
	{
		NSString * stationName = [requestDict objectForKey:@"name"];
		
		NSString * stationInfo = [NSString stringWithContentsOfURL:[NSURL URLWithString:[veliburl stringByAppendingString:stationName]] usedEncoding:NULL error:NULL];
		NSScanner * scanner = [NSScanner scannerWithString:stationInfo];
		int available, free, total, ticket;
		[scanner scanUpToString:@"<available>" intoString:NULL];
		[scanner scanString:@"<available>" intoString:NULL];
		[scanner scanInt:&available];
		[scanner scanUpToString:@"<free>" intoString:NULL];
		[scanner scanString:@"<free>" intoString:NULL];
		[scanner scanInt:&free];
		[scanner scanUpToString:@"<total>" intoString:NULL];
		[scanner scanString:@"<total>" intoString:NULL];
		[scanner scanInt:&total];
		[scanner scanUpToString:@"<ticket>" intoString:NULL];
		[scanner scanString:@"<ticket>" intoString:NULL];
		[scanner scanInt:&ticket];
		
		stationDict = [NSDictionary dictionaryWithObjectsAndKeys:
					   [requestDict objectForKey:@"indexPath"],@"indexPath",
					   stationName,@"name",
					   [NSDate date],@"date",
					   [NSNumber numberWithInt:available],@"available",
					   [NSNumber numberWithInt:free],@"free",
					   [NSNumber numberWithInt:total],@"total",
					   [NSNumber numberWithInt:ticket],@"ticket",
					   nil];
	}
	[self performSelectorOnMainThread:@selector(setStationInfo:) 
						   withObject:stationDict
						waitUntilDone:NO];
	[pool release];
}

- (void) setStationInfo:(NSDictionary *) stationInfo
{
	[self.currentRequests removeObject:[stationInfo objectForKey:@"name"]];
	if([self.currentRequests count]==0)
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	if(stationInfo)
	{
		[self.stationsDictionary setObject:stationInfo forKey:[stationInfo objectForKey:@"name"]];
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[stationInfo objectForKey:@"indexPath"]]
							  withRowAnimation:UITableViewRowAnimationRight];
	}
}

@end

