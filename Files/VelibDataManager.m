//
//  VelibDataManager.m
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "VelibDataManager.h"
#import "Station.h"

#import "NSArrayAdditions.h"

#import <CoreData/CoreData.h>

/****************************************************************************/
#pragma mark -

@interface VelibDataManager () <NSXMLParserDelegate>
@property (nonatomic, retain) NSManagedObjectModel *mom;
@property (nonatomic, retain) NSPersistentStoreCoordinator *psc;
@property (nonatomic, retain) NSManagedObjectContext *moc;

@property BOOL updatingXML;
@property (nonatomic, retain) NSDate *parseDate;
- (void) updateXML;
@end

/****************************************************************************/
#pragma mark -

@implementation VelibDataManager

@synthesize mom, psc, moc;
@synthesize updatingXML, parseDate;

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
	
//		[[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];

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
			[self performSelectorInBackground:@selector(updateXML) withObject:nil];
	}
	return self;
}


- (void) dealloc
{
	self.mom = nil;
	self.psc = nil;
	self.moc = nil;
	self.parseDate = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark -

- (void) updateXML
{
	NSAutoreleasePool * pool = [NSAutoreleasePool new];
	NSData * xml = [NSData dataWithContentsOfURL:[NSURL URLWithString:kVelibStationsListURL]];
	[self performSelectorOnMainThread:@selector(parseXML:) withObject:xml waitUntilDone:NO];
	[pool release];
}

- (void) parseXML:(NSData*)xml
{
	self.updatingXML = YES;

	// Parse
	NSXMLParser * parser = [[[NSXMLParser alloc] initWithData:xml] autorelease];
	parser.delegate = self;
	self.parseDate = [NSDate date];
	[parser parse];
	
	// Remove old stations
	NSFetchRequest * oldStationsRequest = [[NSFetchRequest new] autorelease];
	[oldStationsRequest setEntity:[Station entityInManagedObjectContext:self.moc]];
	[oldStationsRequest setPredicate:[NSPredicate predicateWithFormat:@"%K != %@",@"create_date",self.parseDate]];
	NSError * requestError = nil;
	NSArray * oldStations = [self.moc executeFetchRequest:oldStationsRequest error:&requestError];
	//NSLog(@"Removing %d old stations",[oldStations count]);
	for (Station * oldStation in oldStations) {
		[self.moc deleteObject:oldStation];
	}
	
	// Save
	[self save];
	self.updatingXML = NO;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"marker"])
	{
		Station * station = [[Station fetchStationWithNumber:self.moc number:[attributeDict objectForKey:@"number"]] lastObject];
		if(nil==station)
			station = [Station insertInManagedObjectContext:self.moc];
		station.address = [attributeDict objectForKey:@"address"];
		station.bonusValue = [[attributeDict objectForKey:@"bonus"] boolValue];
		station.fullAddress = [attributeDict objectForKey:@"fullAddress"];
		station.latValue = [[attributeDict objectForKey:@"lat"] doubleValue];
		station.lngValue = [[attributeDict objectForKey:@"lng"] doubleValue];
		station.name = [attributeDict objectForKey:@"name"];
		station.number = [attributeDict objectForKey:@"number"];
		station.openValue = [[attributeDict objectForKey:@"open"] boolValue];
		station.create_date = self.parseDate;
		[station setupCodePostal];
	}
}

- (void) save
{
	NSError * error;
	BOOL success = [self.moc save:&error];
	if(!success)
		NSLog(@"save failed : %@ %@",error, [error userInfo]);
}

@end

