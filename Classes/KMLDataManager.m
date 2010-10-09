//
//  KMLDataManager.m
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Visuamobile. All rights reserved.
//

#import "KMLDataManager.h"

/****************************************************************************/
#pragma mark -

@interface KMLDataManager () <NSXMLParserDelegate>
@property (nonatomic, retain) NSArray * arrondissements;
- (void) scan:(NSString*)kml;
@end

/****************************************************************************/
#pragma mark -

@interface Arrondissement ()
@property (nonatomic, retain) NSString * xmlID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSArray * stations;
@end

/****************************************************************************/
#pragma mark -

@interface Station () 
@property (nonatomic, retain) NSString * xmlID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) CLLocation * location;
@property (nonatomic, assign) Arrondissement * arrondissement;
@end

/****************************************************************************/
#pragma mark -

@implementation KMLDataManager
@synthesize arrondissements;

+ (id) managerWithKML:(NSString*)kml
{
	return [[[self alloc] initWithKML:kml] autorelease];
}

- (id) initWithKML:(NSString*)kml
{
	self = [super init];
	if (self != nil) {
		[self scan:kml];
	}
	return self;
}


- (void) dealloc
{
	self.arrondissements = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark -

- (void) scan:(NSString*)kml
{
	NSScanner * scanner = [NSScanner scannerWithString:kml];
	NSString * tmp;
	CLLocationDegrees tmpLat, tmpLong;
	
	NSMutableArray * arrdts = [NSMutableArray arrayWithCapacity:50];
	NSMutableArray * stations = [NSMutableArray arrayWithCapacity:100];

	BOOL hasArrondissement = [scanner scanUpToString:@"Folder" intoString:NULL];
	while(hasArrondissement)
	{
		[scanner scanString:@"Folder" intoString:NULL];
		Arrondissement * arrdt = [Arrondissement new];
		if([scanner scanUpToString:@"id='" intoString:NULL] && [scanner scanUpToString:@"'" intoString:&tmp])
			arrdt.xmlID = tmp;
		if([scanner scanUpToString:@"<name>" intoString:NULL] && [scanner scanUpToString:@"</name>" intoString:&tmp])
			arrdt.name = tmp;

		[stations removeAllObjects];
		
		BOOL hasStation = [scanner scanUpToString:@"Placemark" intoString:NULL];
		while(hasArrondissement)
		{
			[scanner scanString:@"Placemark" intoString:NULL];
			Station * station = [Station new];
			if([scanner scanUpToString:@"id='" intoString:NULL] && [scanner scanUpToString:@"'" intoString:&tmp])
				station.xmlID = tmp;
			if([scanner scanUpToString:@"<name>" intoString:NULL] && [scanner scanUpToString:@"</name>" intoString:&tmp])
				station.name = tmp;
			if([scanner scanUpToString:@"<b>" intoString:NULL] && [scanner scanUpToString:@"</b>" intoString:&tmp])
				station.displayName = tmp;
			if([scanner scanUpToString:@"<address>" intoString:NULL] && [scanner scanUpToString:@"</address>" intoString:&tmp])
				station.address = tmp;
			if([scanner scanUpToString:@"<coordinates>" intoString:NULL] && [scanner scanDouble:&tmpLat] && [scanner scanDouble:&tmpLong])
				station.location = [[[CLLocation alloc] initWithLatitude:tmpLat longitude:tmpLong] autorelease];
			
			station.arrondissement = arrdt;
			[stations addObject:station];
			
			hasStation = [scanner scanUpToString:@"Placemark" intoString:NULL];
		}			
		
		arrdt.stations = stations;
		
		[arrdts addObject:arrdt];
		
		hasArrondissement = [scanner scanUpToString:@"Folder" intoString:NULL];
	}
	
	self.arrondissements = arrdts;
}

@end

/****************************************************************************/
#pragma mark -

@implementation Arrondissement
@synthesize xmlID, name, stations;

- (void) dealloc
{
	self.xmlID = nil;
	self.name = nil;
	self.stations = nil;
	[super dealloc];
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"Arrondissement %@ (%d stations)",
			self.name, self.stations.count];
}

@end

/****************************************************************************/
#pragma mark -

@implementation Station
@synthesize xmlID, name, displayName, address, location, arrondissement;
@synthesize available, free, total, ticket;

- (void) dealloc
{
	self.xmlID = nil;
	self.name = nil;
	self.displayName = nil;
	self.address = nil;
	self.location = nil;
	self.arrondissement = nil;
	[super dealloc];
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"%@ : Station %@ : %@ (%@ - %@)\n\t%s\t%02d/%02d/%02d",
			self.arrondissement.name, self.name, self.displayName, self.address, self.location,
			self.ticket?"+":"", self.available, self.free, self.total];
}

@end

