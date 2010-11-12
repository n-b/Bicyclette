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
@property (nonatomic, retain) NSDate *parseDate;

@end

/****************************************************************************/
#pragma mark -

@implementation VelibDataManager

@synthesize mom, psc, moc;
@synthesize parseDate;

- (id) init
{
	return [self initWithVelibXML:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"carto" ofType:@"xml"]]];
}

- (id) initWithVelibXML:(NSData*)xml
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
		
		// Parse
		NSXMLParser * parser = [[[NSXMLParser alloc] initWithData:xml] autorelease];
		parser.delegate = self;
		self.parseDate = [NSDate date];
		[parser parse];
		
		// Remove old stations
		NSFetchRequest * oldStationsRequest = [NSFetchRequest new];
		[oldStationsRequest setEntity:[Station entityInManagedObjectContext:self.moc]];
		[oldStationsRequest setPredicate:[NSPredicate predicateWithFormat:@"%K != %@",@"create_date",self.parseDate]];
		NSError * requestError = nil;
		NSArray * oldStations = [self.moc executeFetchRequest:oldStationsRequest error:&requestError];
		NSLog(@"Removing %d old stations",[oldStations count]);
		for (Station * oldStation in oldStations) {
			[self.moc deleteObject:oldStation];
		}
		
		// Save
		NSError * saveError = nil;
		[self.moc save:&saveError];
		if(saveError)
			NSLog(@"Save error : %@ %@",[saveError localizedDescription], [saveError userInfo]);
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

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
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

/****************************************************************************/
#pragma mark -

- (NSFetchRequest*) stations
{
	NSFetchRequest * fetchRequest = [NSFetchRequest new];
	[fetchRequest setEntity:[Station entityInManagedObjectContext:self.moc]];
	 
	 NSArray * sortDescriptors =  [NSArray arrayWithObjects:
								   [[[NSSortDescriptor alloc] initWithKey:@"code_postal" ascending:YES] autorelease],
								   [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease],
								   nil];
	 [fetchRequest setSortDescriptors:sortDescriptors];

	 return [fetchRequest autorelease];
}

@end

