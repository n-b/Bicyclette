//
//  VelibDataManager.m
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "VelibDataManager.h"
#import "Station.h"
#import "Region.h"

#import "NSArrayAdditions.h"

#import <CoreData/CoreData.h>

/****************************************************************************/
#pragma mark -

@interface VelibDataManager () <NSXMLParserDelegate>
@property (nonatomic, retain) NSManagedObjectModel *mom;
@property (nonatomic, retain) NSPersistentStoreCoordinator *psc;
@property (nonatomic, retain) NSManagedObjectContext *moc;
// -
@property BOOL updatingXML;
@property (nonatomic, retain) NSDate *parseDate;
- (void) updateXML;
// -
@property (nonatomic, retain) NSURLConnection * updateConnection;
@property (nonatomic, retain) NSMutableData * updateData;
- (void) parseXML:(NSData*)xml;
// -
@property (nonatomic, retain) NSDictionary * stationsHardcodedFixes;
// -
@property (readonly, nonatomic, readwrite) MKCoordinateRegion coordinateRegion;
@end

/****************************************************************************/
#pragma mark -

@implementation VelibDataManager

@synthesize mom, psc, moc;
@synthesize updatingXML, updateConnection, updateData, parseDate;
@synthesize stationsHardcodedFixes;
@synthesize coordinateRegion;

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		// Create mom
		mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Velib" ofType:@"mom"]]]; 

		// Create psc
		psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.mom];
		NSError *error = nil;
		NSURL *storeURL = [NSURL fileURLWithPath: [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent: @"Velib.sqlite"]];
	
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"DebugRemoveStore"])
		{
			NSLog(@"Removing data store");
			[[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
//			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DebugRemoveStore"];
		}

		if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
		{
			NSLog(@"Unresolved error when opening store %@, %@", error, [error userInfo]);
			if( error.code == NSPersistentStoreIncompatibleVersionHashError )
			{
				NSLog(@"trying to remove the existing db");
				[[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
				[psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];	
			}
			else
				abort();
		}
		
		// Create moc
		moc = [[NSManagedObjectContext alloc] init];
		[moc setPersistentStoreCoordinator:self.psc];
		[moc setUndoManager:nil];
		
		// Find if I need to update
		NSFetchRequest * createDateRequest = [[NSFetchRequest new] autorelease];
		[createDateRequest setEntity:[Station entityInManagedObjectContext:self.moc]];
		[createDateRequest setFetchLimit:1];
		NSDate * createDate = [[[self.moc executeFetchRequest:createDateRequest error:NULL] lastObject] create_date];
		
		BOOL needUpdate = (nil==createDate || [[NSDate date] timeIntervalSinceDate:createDate] > [[NSUserDefaults standardUserDefaults] doubleForKey:@"DatabaseReloadInterval"]);
		if(needUpdate)
			[self performSelector:@selector(updateXML) withObject:nil afterDelay:0];
	}
	return self;
}


- (void) dealloc
{
	self.mom = nil;
	self.psc = nil;
	self.moc = nil;
	self.parseDate = nil;
	self.stationsHardcodedFixes = nil;
	
	[self.updateConnection cancel];
	self.updateConnection = nil;
	self.updateData = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark -

- (NSDictionary*) stationsHardcodedFixes
{
	if(nil==stationsHardcodedFixes)
	{
		NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VelibHardcodedFixes" ofType:@"plist"]];
		self.stationsHardcodedFixes = [dict objectForKey:@"stations"];
	}
	return [[stationsHardcodedFixes retain] autorelease];
}

/****************************************************************************/
#pragma mark URL request 

- (void) updateXML
{
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kVelibStationsListURL]];
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
	[self parseXML:self.updateData];
	self.updateData = nil;	
}

+ (NSSet*) keyPathsForValuesAffectingDownloadingUpdate
{
	return [NSSet setWithObject:@"updateConnection"];
}

- (BOOL) downloadingUpdate
{
	return self.updateConnection!=nil;
}

- (void) save
{
	NSError * error;
	BOOL success = [self.moc save:&error];
	if(!success)
		NSLog(@"save failed : %@ %@",error, [error userInfo]);
}

/****************************************************************************/
#pragma mark Parsing

- (void) parseXML:(NSData*)xml
{
	self.updatingXML = YES;

	// Save old favorites
	NSFetchRequest * favoritesRequest = [[NSFetchRequest new] autorelease];
	[favoritesRequest setEntity:[Station entityInManagedObjectContext:self.moc]];
	[favoritesRequest setPredicate:[NSPredicate predicateWithFormat:@"favorite_index != -1"]];
	[favoritesRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"number",@"favorite_index",nil]];
	[favoritesRequest setResultType:NSDictionaryResultType];
	NSError * requestError = nil;
	NSArray * oldFavorites = [self.moc executeFetchRequest:favoritesRequest error:&requestError];
	NSLog(@"old favorites : %@",oldFavorites);
	
	// Remove old stations
	NSFetchRequest * oldStationsRequest = [[NSFetchRequest new] autorelease];
	[oldStationsRequest setEntity:[Station entityInManagedObjectContext:self.moc]];
	NSArray * oldStations = [self.moc executeFetchRequest:oldStationsRequest error:&requestError];
	NSLog(@"Removing %d old stations",[oldStations count]);
	for (Station * oldStation in oldStations) {
		[self.moc deleteObject:oldStation];
	}
	
	// Parse
	NSXMLParser * parser = [[[NSXMLParser alloc] initWithData:xml] autorelease];
	parser.delegate = self;
	self.parseDate = [NSDate date];
	[parser parse];
	
	// Restore favorites
	for (NSDictionary * favoriteEntry in oldFavorites) {
		Station * station = [[Station fetchStationWithNumber:self.moc number:[favoriteEntry objectForKey:@"number"]] lastObject];
		NSLog(@"restoring station %@",[favoriteEntry objectForKey:@"number"]);
		if(nil==station)
			NSLog(@"Previously favorite station %@ has disappeared",[favoriteEntry objectForKey:@"number"]);
		else
			station.favorite_index = [favoriteEntry objectForKey:@"favorite_index"];
	}
	
	// Compute regions coordinates
	NSFetchRequest * regionsRequest = [[NSFetchRequest new] autorelease];
	[regionsRequest setEntity:[Region entityInManagedObjectContext:self.moc]];
	NSArray * regions = [self.moc executeFetchRequest:regionsRequest error:&requestError];
	[regions makeObjectsPerformSelector:@selector(setupCoordinates)];
			
	// Save
	[self save];
	self.updatingXML = NO;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"marker"])
	{
		Station * station = [Station insertInManagedObjectContext:self.moc];
		[station setValuesForKeysWithDictionary:attributeDict]; // Yay!
		NSDictionary * fixes = [self.stationsHardcodedFixes objectForKey:station.number];
		if(fixes)
		{
			NSLog(@"using hardcoded fixes for %@ : %@",station.number,fixes);
			[station setValuesForKeysWithDictionary:fixes]; // Yay! again
		}
		[station setupCodePostal];
		station.create_date = self.parseDate;
	}
}

- (MKCoordinateRegion) coordinateRegion
{
	if(coordinateRegion.center.latitude == 0 &&
	   coordinateRegion.center.longitude == 0 &&
	   coordinateRegion.span.latitudeDelta == 0 &&
	   coordinateRegion.span.longitudeDelta == 0 )
	{
		NSFetchRequest * regionsRequest = [[NSFetchRequest new] autorelease];
		[regionsRequest setEntity:[Region entityInManagedObjectContext:self.moc]];
		NSError * requestError = nil;
		NSArray * regions = [self.moc executeFetchRequest:regionsRequest error:&requestError];

		NSNumber * minLat = [regions valueForKeyPath:@"@min.minLat"];
		NSNumber * maxLat = [regions valueForKeyPath:@"@max.maxLat"];
		NSNumber * minLng = [regions valueForKeyPath:@"@min.minLng"];
		NSNumber * maxLng = [regions valueForKeyPath:@"@max.maxLng"];
		
		CLLocationCoordinate2D center;
		center.latitude = ([minLat doubleValue] + [maxLat doubleValue]) / 2.0f;
		center.longitude = ([minLng doubleValue] + [maxLng doubleValue]) / 2.0f; // This is very wrong ! Do I really need a if?
		MKCoordinateSpan span;
		span.latitudeDelta = fabs([minLat doubleValue] - [maxLat doubleValue]);
		span.longitudeDelta = fabs([minLng doubleValue] - [maxLng doubleValue]);
		self.coordinateRegion = MKCoordinateRegionMake(center, span);
	}
	return coordinateRegion;
}

@end

