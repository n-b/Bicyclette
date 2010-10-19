//
//  VelibDataManager.m
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "VelibDataManager.h"
#import "NSStringAdditions.h"
#import "NSArrayAdditions.h"

/****************************************************************************/
#pragma mark -
@interface NSString (KVCBoolHandling)
- (char) charValue; // Needed because KVC's handling of BOOLs in setValuesForKeysWithDictionary is flakey
@end

@implementation NSString (KVCBoolHandling)
- (char) charValue
{
	return self.boolValue;
}
@end

/****************************************************************************/
#pragma mark -

@interface VelibDataManager () <NSXMLParserDelegate>
@property (nonatomic, retain) NSMutableArray * mutableStations;
@property (nonatomic, retain) NSMutableArray * mutableSections;
@end

/****************************************************************************/
#pragma mark -

@interface Section ()
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSMutableArray * mutableStations;
@end

/****************************************************************************/
#pragma mark -

@interface Station () <NSXMLParserDelegate>
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * fullAddress;
@property (nonatomic) CLLocationDegrees lat;
@property (nonatomic) CLLocationDegrees lng;
@property (nonatomic) BOOL open;
@property (nonatomic) BOOL bonus;
// Computed properties
@property (nonatomic, readonly) NSString * codePostal;

@property (nonatomic, assign) Section * section;

@property (nonatomic, retain) NSURLConnection * connection;
@property (nonatomic, retain) NSMutableData * data;
@property (nonatomic, retain) NSDate * refreshDate;
@end

/****************************************************************************/
#pragma mark -

@implementation VelibDataManager
@synthesize mutableStations, mutableSections;

- (id) init
{
	return [self initWithVelibXML:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"carto" ofType:@"xml"]]];
}

- (id) initWithVelibXML:(NSData*)xml
{
	self = [super init];
	if (self != nil) 
	{
		self.mutableStations = [NSMutableArray arrayWithCapacity:1000];
		self.mutableSections = [NSMutableArray arrayWithCapacity:40];
		NSXMLParser * parser = [[[NSXMLParser alloc] initWithData:xml] autorelease];
		parser.delegate = self;
		[parser parse];
		
		[self.mutableSections sortWithProperty:@"name"];
		for (Section * section in self.sections)
			[section.mutableStations sortWithProperty:@"number"];
	}
	return self;
}


- (void) dealloc
{
	self.mutableStations = nil;
	self.mutableSections =  nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark -

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"marker"])
	{
		Station * station = [[[Station alloc] init] autorelease];
		[station setValuesForKeysWithDictionary:attributeDict];
		[self.mutableStations addObject:station];
		NSString * sectionName = station.codePostal;
		Section * section = [self.sections firstObjectWithValue:sectionName forKey:@"name"];
		if(nil==section)
		{
			section = [[[Section alloc] init] autorelease];
			section.name = sectionName;
			[self.mutableSections addObject:section];
		}
		[section.mutableStations addObject:station];
		station.section = section;
	}
}

- (NSArray *) stations
{
	return self.mutableStations;
}

- (NSArray *) sections
{
	return self.mutableSections;
}

@end

/****************************************************************************/
#pragma mark -
@implementation Section
@synthesize name, mutableStations;

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		self.mutableStations = [NSMutableArray arrayWithCapacity:1000];
	}
	return self;
}


- (void) dealloc
{
	self.mutableStations = nil;
	[super dealloc];
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"Section %@ (%d stations)",self.name, self.stations.count];
}
- (NSArray *) stations
{
	return self.mutableStations;
}

@end

/****************************************************************************/
#pragma mark -

@implementation Station
@synthesize name, number, address, fullAddress, lat, lng, open, bonus;
@synthesize available, free, total, ticket;
@synthesize section;
@synthesize data,connection,refreshDate;

- (void) dealloc
{
	self.name = nil;
	self.number = nil;
	self.address = nil;
	self.fullAddress = nil;
	self.section = nil;
	self.data = nil;
	self.connection = nil;
	self.refreshDate = nil;
	[super dealloc];
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"Station %@ (%@): %@ (%f,%f) %s %s\n\t%s\t%02d/%02d/%02d",
			self.name, self.number, self.address, self.lat, self.lng, self.open?"O":"F", self.bonus?"+":"",
			self.ticket?"+":"", self.available, self.free, self.total];
}

- (NSString *) codePostal
{
	NSAssert2([self.fullAddress hasPrefix:self.address],@"full address \"%@\" does not begin with address \"%@\"", self.fullAddress, self.address);
	NSString * endOfAddress = [self.fullAddress stringByDeletingPrefix:self.address];
	endOfAddress = [endOfAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString * codePostal = nil;
	if(endOfAddress.length>=5)
		codePostal = [endOfAddress substringToIndex:5];
	else
	{
		char firstChar = [self.number characterAtIndex:0];
		switch (firstChar) {
			case '0': case '1':				// Paris
				codePostal = [NSString stringWithFormat:@"750%@",[self.number substringToIndex:2]];
				break;
			case '2': case '3': case '4':	// Banlieue
				codePostal = [NSString stringWithFormat:@"9%@0",[self.number substringToIndex:3]];
				break;
			default:						// Stations Mobiles et autres bugs
				codePostal = @"75000";
				break;
		}

		NSLog(@"endOfAddress \"%@\" trop court, %@, trouvé %@",endOfAddress, self.name, codePostal);
	}
	NSAssert1([codePostal rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound,@"codePostal %@ contient des caractères invalides",codePostal);
	return codePostal;	
}


- (void) refresh
{
	if(self.connection!=nil)
	{
		NSLog(@"requete déjà en cours %@",self.number);
		return;
	}
	if([self.refreshDate timeIntervalSinceNow] < -5)
	{
		NSLog(@"requete trop récente %@",self.number);
		return;
	}

	NSLog(@"start requete %@",self.number);
#define veliburl @"http://www.velib.paris.fr/service/stationdetails/"
	NSURL * url = [NSURL URLWithString:[veliburl stringByAppendingString:self.number]];
	self.connection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
	self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"FAIL requete %@",self.number);
	self.data = nil;	
	self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)moredata
{
	[self.data appendData:moredata];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"DONE requete %@",self.number);
	NSString * stationInfo = [NSString stringWithData:self.data encoding:NSUTF8StringEncoding ];
	if(stationInfo)
	{
		NSScanner * scanner = [NSScanner scannerWithString:stationInfo];
		int tmp;
		[scanner scanUpToString:@"<available>" intoString:NULL];
		[scanner scanString:@"<available>" intoString:NULL];
		[scanner scanInt:&tmp];
		self.available = tmp;
		[scanner scanUpToString:@"<free>" intoString:NULL];
		[scanner scanString:@"<free>" intoString:NULL];
		[scanner scanInt:&tmp];
		self.free = tmp;
		[scanner scanUpToString:@"<total>" intoString:NULL];
		[scanner scanString:@"<total>" intoString:NULL];
		[scanner scanInt:&tmp];
		self.total = tmp;
		[scanner scanUpToString:@"<ticket>" intoString:NULL];
		[scanner scanString:@"<ticket>" intoString:NULL];
		[scanner scanInt:&tmp];
		self.ticket = tmp;
		self.refreshDate = [NSDate date];
	}
	self.data = nil;
	self.connection = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StationUpdated" object:self];
}
@end

