//
//  VelibDataManager.m
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "VelibDataManager.h"
#import "Station.h"
#import "Section.h"

#import "NSArrayAdditions.h"

#import <CoreData/CoreData.h>

/****************************************************************************/
#pragma mark -

@interface VelibDataManager () <NSXMLParserDelegate>
@property (nonatomic, retain) NSManagedObjectModel *mom;
@property (nonatomic, retain) NSPersistentStoreCoordinator *psc;
@property (nonatomic, retain) NSManagedObjectContext *moc;
@end

/****************************************************************************/
#pragma mark -

@implementation VelibDataManager

@synthesize mom, psc, moc;

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
		[parser parse];
		
		[self.moc save:NULL];
	}
	return self;
}


- (void) dealloc
{
	self.mom = nil;
	self.psc = nil;
	self.moc = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark -

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	NSUInteger station_sort_index = 0;
	if([elementName isEqualToString:@"marker"])
	{
		Station * station = [Station insertInManagedObjectContext:self.moc];
		station.address = [attributeDict objectForKey:@"address"];
		station.bonusValue = [[attributeDict objectForKey:@"bonus"] boolValue];
		station.fullAddress = [attributeDict objectForKey:@"fullAddress"];
		station.latValue = [[attributeDict objectForKey:@"lat"] doubleValue];
		station.lngValue = [[attributeDict objectForKey:@"lng"] doubleValue];
		station.name = [attributeDict objectForKey:@"name"];
		station.number = [attributeDict objectForKey:@"number"];
		station.openValue = [[attributeDict objectForKey:@"open"] boolValue];

		[station setupCodePostal]; 
		
		station.sort_indexValue = station_sort_index++;
				
		Section * section = [self sectionWithName:station.code_postal];
		if(nil==section)
		{
			section = [Section insertInManagedObjectContext:self.moc];
			section.name = station.code_postal;
		}
		station.section = section;
	}
}

/****************************************************************************/
#pragma mark -

- (Section*) sectionWithName:(NSString*)name
{
	return [[Section fetchSectionWithName:self.moc name:name] lastObject];
}

- (NSFetchRequest*) sections
{
	NSFetchRequest *fetchRequest = [self.mom fetchRequestFromTemplateWithName:@"sections"
														substitutionVariables:[NSDictionary dictionary]];
	static BOOL initializedSortDescriptor = NO;
	if(!initializedSortDescriptor)
	{
		[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease]]];
		initializedSortDescriptor = YES;
	}
	return fetchRequest;
}

- (NSFetchRequest*) stations
{
	NSFetchRequest *fetchRequest = [self.mom fetchRequestFromTemplateWithName:@"stations"
														substitutionVariables:[NSDictionary dictionary]];
	static BOOL initializedSortDescriptor = NO;
	if(!initializedSortDescriptor)
	{
		NSArray * sortDescriptors =  [NSArray arrayWithObjects:
									  [[[NSSortDescriptor alloc] initWithKey:@"code_postal" ascending:YES] autorelease],
									  [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease],
									  nil];
		
		[fetchRequest setSortDescriptors:sortDescriptors];
		initializedSortDescriptor = YES;
	}
	return fetchRequest;
}

@end

