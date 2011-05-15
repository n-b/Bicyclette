//
//  VelibModel.m
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "VelibModel.h"
#import "Station.h"
#import "Region.h"
#import "NSArrayAdditions.h"

#import "DataUpdater.h"

/****************************************************************************/
#pragma mark -

@interface VelibModel () <DataUpdaterDelegate, NSXMLParserDelegate>
@property (nonatomic, retain) DataUpdater * updater;
@property BOOL updatingXML;
// -
@property (nonatomic, retain) NSDictionary * stationsHardcodedFixes;
// -
@property (readonly, nonatomic, readwrite) MKCoordinateRegion coordinateRegion;
@end

/****************************************************************************/
#pragma mark -

@implementation VelibModel

@synthesize updater;
@synthesize updatingXML;
@synthesize stationsHardcodedFixes;
@synthesize coordinateRegion;

- (id)init {
    self = [super init];
    if (self) {
        self.updater = [DataUpdater updaterWithDelegate:self];
    }
    return self;
}
- (void) dealloc
{
    self.updater = nil;
	self.stationsHardcodedFixes = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark Hardcoded Fixes

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
#pragma mark Parsing

- (NSURL*) urlForUpdater:(DataUpdater *)updater
{
    return [NSURL URLWithString:kVelibStationsListURL];    
}

- (void) updater:(DataUpdater*)updater finishedReceivingData:(NSData*)xml
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
			NSLog(@"using hardcoded fixes for %@.\n\tReceived Data : %@.\n\tFixes : %@",station.number, attributeDict, fixes);
			[station setValuesForKeysWithDictionary:fixes]; // Yay! again
		}
        BOOL valid = [station setupCodePostal];
		if(!valid)
        {
            NSLog(@"Invalid data : %@",attributeDict);
            [self.moc deleteObject:station];
        }
	}
}

/****************************************************************************/
#pragma mark Coordinates

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

