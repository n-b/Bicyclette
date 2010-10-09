//
//  RootViewController.m
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "RootViewController.h"
#import "StationCell.h"
#import "BicycletteDefaults.h"
#import "CLLocation+Direction.h"

#define kStalenessInterval 30

#define kFavoritesPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] \
stringByAppendingPathComponent:@"favorites.plist"]

#define kStationsDictPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] \
stringByAppendingPathComponent:@"stationsDict.plist"]

@interface RootViewController() <CLLocationManagerDelegate>
@property (nonatomic,retain) NSArray * arrdtArray;
@property (nonatomic,retain) NSMutableDictionary * stationsDictionary;
@property (nonatomic,retain) NSMutableSet * currentRequests;
@property (nonatomic,retain) NSMutableArray * favoritesArray;

@property (nonatomic,readonly) UITableView * tableView;
@property BOOL	onlyShowFavorites;

- (NSArray*)stationsForSection:(NSInteger)section;

- (void) appWillTerminate:(NSNotification*) notif;
- (void) requestInfo:(NSDictionary *) requestDict;
- (void) setStationInfo:(NSDictionary *) dictionary;
@end

/****************************************************************************/
#pragma mark -

@implementation RootViewController
@synthesize arrdtArray, stationsDictionary, currentRequests, favoritesArray;
@synthesize favoritesButton, onlyShowFavorites;
@synthesize titleToggle;

- (void) awakeFromNib
{
	self.arrdtArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"velib-all" ofType:@"plist"]];
	self.stationsDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:kStationsDictPath];
	if(self.stationsDictionary==nil)
		self.stationsDictionary = [NSMutableDictionary dictionary];
	self.favoritesArray = [NSMutableArray arrayWithContentsOfFile:kFavoritesPath];
	if(self.favoritesArray==nil)
		self.favoritesArray = [NSMutableArray array];
	self.currentRequests = [NSMutableSet set];

	locationManager = [CLLocationManager new];
	locationManager.delegate = self;
	[locationManager startUpdatingLocation];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:)
												 name:UIApplicationWillTerminateNotification
											   object:[UIApplication sharedApplication]];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[locationManager release];
	self.arrdtArray = nil;
	self.stationsDictionary = nil;
	self.currentRequests = nil;
	self.favoritesArray = nil;
	self.tableView = nil;
	self.favoritesButton = nil;
	self.titleToggle = nil;
	[super dealloc];
}

- (void) appWillTerminate:(NSNotification*) notif
{
	[self.stationsDictionary writeToFile:kStationsDictPath atomically:YES];
	[self.favoritesArray writeToFile:kFavoritesPath atomically:YES];
	[[NSUserDefaults standardUserDefaults] setFloat:self.tableView.contentOffset.y forKey:@"TableOffset"];
	[[NSUserDefaults standardUserDefaults] setBool:onlyShowFavorites forKey:@"OnlyShowFavorites"];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.titleView = self.titleToggle;
}

- (void) viewDidUnload
{
	self.tableView = nil;
	self.favoritesButton = nil;
	self.titleToggle = nil;
	[super viewDidUnload];
}

- (UITableView*) tableView
{
	return (UITableView*)self.view;
}


- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	CGPoint offset = CGPointZero;
	offset.y = [[NSUserDefaults standardUserDefaults] floatForKey:@"TableOffset"];
	self.tableView.contentOffset = offset;
	onlyShowFavorites = [[NSUserDefaults standardUserDefaults] boolForKey:@"OnlyShowFavorites"];
	self.favoritesButton.style = onlyShowFavorites?UIBarButtonItemStyleDone:UIBarButtonItemStylePlain;
	self.titleToggle.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] boolForKey:@"ParkingWanted"];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self performSelector:@selector(sendRequests) withObject:nil afterDelay:.5 inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

/****************************************************************************/
#pragma mark -

- (IBAction) toggleFavorites
{
	onlyShowFavorites = !onlyShowFavorites;
	self.favoritesButton.style = onlyShowFavorites?UIBarButtonItemStyleDone:UIBarButtonItemStylePlain;
	[self.tableView reloadData];
}

- (IBAction) toggleWanted
{
	[[NSUserDefaults standardUserDefaults] setBool:self.titleToggle.selectedSegmentIndex forKey:@"ParkingWanted"];
	[self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
						  withRowAnimation:UITableViewRowAnimationNone];
}


/****************************************************************************/
#pragma mark Table view data source


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [arrdtArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(onlyShowFavorites)
		return nil;
	return [[arrdtArray objectAtIndex:section] objectForKey:@"name"];
}

// helper
- (NSArray*)stationsForSection:(NSInteger)section
{
	NSArray * arrdtStations = [[arrdtArray objectAtIndex:section] objectForKey:@"stations"];
	if(onlyShowFavorites)
		return [arrdtStations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name IN %@",self.favoritesArray]];
	return arrdtStations;
}

// index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	if(onlyShowFavorites)
		return nil;
	NSArray * names = [arrdtArray valueForKey:@"name"];
	NSMutableArray * titles = [NSMutableArray arrayWithCapacity:[names count]];
	for (NSString * name in names) {
		int number = [name intValue];
		if(number!=0)
			[titles addObject:[NSString stringWithFormat:@"%d",number]];
		else
			[titles addObject:[name substringToIndex:1]];
	}
	return titles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return index;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self stationsForSection:section] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	StationCell * cell = [StationCell reusableCellForTable:tableView];
	NSDictionary * station = [[self stationsForSection:indexPath.section] objectAtIndex:indexPath.row];
	NSString * stationName = [station objectForKey:@"name"];
	cell.station = station;
	cell.stationInfo = [stationsDictionary objectForKey:stationName];
	cell.favorite = [self.favoritesArray containsObject:stationName];
	cell.loading = [self.currentRequests containsObject:stationName];
	
	CLLocation * currentLocation = [[NSUserDefaults standardUserDefaults] lastKnownLocation];
	if(currentLocation)
	{
		NSScanner * coordsScanner = [NSScanner scannerWithString:[station objectForKey:@"coordinates"]];
		CLLocationDegrees longitude, latitude;
		[coordsScanner scanDouble:&longitude];
		[coordsScanner scanString:@"," intoString:NULL];
		[coordsScanner scanDouble:&latitude];
		
		CLLocation * stationLocation = [[[CLLocation alloc] initWithLatitude:latitude
																   longitude:longitude] autorelease];
		cell.distance = [stationLocation getDistanceFrom:[[NSUserDefaults standardUserDefaults] lastKnownLocation]];
		cell.direction = [stationLocation directionFrom:[[NSUserDefaults standardUserDefaults] lastKnownLocation]];
	}

    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	if(onlyShowFavorites)
		return;
	NSString * stationName = [[[self stationsForSection:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
	if([self.favoritesArray containsObject:stationName])
		[self.favoritesArray removeObject:stationName];
	else
		[self.favoritesArray addObject:stationName];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							  withRowAnimation:UITableViewRowAnimationFade];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(onlyShowFavorites)
		return nil;
	else
		return indexPath;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(onlyShowFavorites)
		return UITableViewCellEditingStyleDelete;
	else
		return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(onlyShowFavorites && editingStyle==UITableViewCellEditingStyleDelete)
	{
		NSString * stationName = [[[self stationsForSection:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
		if([self.favoritesArray containsObject:stationName])
			[self.favoritesArray removeObject:stationName];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							  withRowAnimation:UITableViewRowAnimationFade];
	}
}



/****************************************************************************/
#pragma mark Requests

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
		NSDictionary * station = [[self stationsForSection:indexPath.section] objectAtIndex:indexPath.row];
		NSString * stationName = [station objectForKey:@"name"];
		if([self.currentRequests containsObject:stationName])
		{
			NSLog(@"skipping (already requesting) %@",stationName);
			continue;
		}
		NSDictionary * stationInfo = [stationsDictionary objectForKey:stationName];
		if(stationInfo && [[NSDate date] timeIntervalSinceDate:[stationInfo objectForKey:@"date"]] < kStalenessInterval)
		{
			NSLog(@"skipping (recent status) %@",stationName);
			continue;
		}
		[self.currentRequests addObject:stationName];
		[self performSelectorInBackground:@selector(requestInfo:) 
							   withObject:[NSDictionary dictionaryWithObjectsAndKeys:
										   indexPath,@"indexPath",
										   stationName,@"name",
										   nil]];
	}
	[self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
						  withRowAnimation:UITableViewRowAnimationNone];
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
		NSString * stationInfo = [NSString stringWithContentsOfURL:[NSURL URLWithString:[veliburl stringByAppendingString:[requestDict objectForKey:@"name"]]] usedEncoding:NULL error:NULL];
		if(stationInfo)
		{
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
						   [NSDate date],@"date",
						   [NSNumber numberWithInt:available],@"available",
						   [NSNumber numberWithInt:free],@"free",
						   [NSNumber numberWithInt:total],@"total",
						   [NSNumber numberWithInt:ticket],@"ticket",
						   nil];
		}
	}
	NSMutableDictionary * mutableDict = [NSMutableDictionary dictionaryWithDictionary:requestDict];
	[mutableDict addEntriesFromDictionary:stationDict],
	[self performSelectorOnMainThread:@selector(setStationInfo:) 
						   withObject:mutableDict
						waitUntilDone:NO];
	[pool release];
}

- (void) setStationInfo:(NSDictionary *) stationInfo
{
	[self.currentRequests removeObject:[stationInfo objectForKey:@"name"]];

	if([stationInfo objectForKey:@"date"])
	{
		NSMutableDictionary * dictWithoutIndexPath = [NSMutableDictionary dictionaryWithDictionary:stationInfo];
		[dictWithoutIndexPath removeObjectForKey:@"indexPath"];
		[dictWithoutIndexPath removeObjectForKey:@"name"];
		[self.stationsDictionary setObject:dictWithoutIndexPath forKey:[stationInfo objectForKey:@"name"]];
		if([[self.tableView indexPathsForVisibleRows] containsObject:[stationInfo objectForKey:@"indexPath"]])
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[stationInfo objectForKey:@"indexPath"]]
								  withRowAnimation:UITableViewRowAnimationRight];
	}
}

/****************************************************************************/
#pragma mark GPS

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	[[NSUserDefaults standardUserDefaults] setLastKnownLocation:newLocation];
	[self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
						  withRowAnimation:UITableViewRowAnimationNone];
}

@end

