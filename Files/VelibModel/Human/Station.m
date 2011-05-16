#import "Station.h"
#import "VelibModel.h"
#import "Region.h"
#import "NSStringAdditions.h"

/****************************************************************************/
#pragma mark -

NSString * const StationFavoriteDidChangeNotification = @"StationFavoriteDidChange";

@interface Station () 
@property (nonatomic, retain) NSURLConnection * connection;
@property (nonatomic, retain) NSMutableData * data;
@property (nonatomic, retain) CLLocation * location;
@end


/****************************************************************************/
#pragma mark -

@implementation Station

@synthesize data,connection;
@synthesize location;

- (NSString *) description
{
	return [NSString stringWithFormat:@"Station %@ (%@): %@ (%f,%f) %s %s\n\t%s\t%02d/%02d/%02d",
			self.name, self.number, self.address, self.latValue, self.lngValue, self.openValue?"O":"F", self.bonusValue?"+":"",
			self.status_ticketValue?"+":"", self.status_availableValue, self.status_freeValue, self.status_totalValue];
}

- (void) dealloc
{
	self.location = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark -

- (void) refresh
{
	if(self.connection!=nil)
	{
		//NSLog(@"requete déjà en cours %@",self.number);
		return;
	}
	if(self.status_date && [[NSDate date] timeIntervalSinceDate:self.status_date] < [[NSUserDefaults standardUserDefaults] doubleForKey:@"StationRefreshInterval"]) // 15 seconds
	{
		//NSLog(@"requete trop récente %@",self.number);
		return;
	}
	
	//NSLog(@"start requete %@",self.number);
	NSURL * url = [NSURL URLWithString:[kVelibStationsStatusURL stringByAppendingString:self.number]];
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
	//NSLog(@"DONE requete %@",self.number);
	NSString * stationInfo = [NSString stringWithData:self.data encoding:NSUTF8StringEncoding ];
	if(stationInfo)
	{
		NSScanner * scanner = [NSScanner scannerWithString:stationInfo];
		int tmp;
		[scanner scanUpToString:@"<available>" intoString:NULL];
		[scanner scanString:@"<available>" intoString:NULL];
		[scanner scanInt:&tmp];
		self.status_availableValue = (short)tmp;
		[scanner scanUpToString:@"<free>" intoString:NULL];
		[scanner scanString:@"<free>" intoString:NULL];
		[scanner scanInt:&tmp];
		self.status_freeValue = (short)tmp;
		[scanner scanUpToString:@"<total>" intoString:NULL];
		[scanner scanString:@"<total>" intoString:NULL];
		[scanner scanInt:&tmp];
		self.status_totalValue = (short)tmp;
		[scanner scanUpToString:@"<ticket>" intoString:NULL];
		[scanner scanString:@"<ticket>" intoString:NULL];
		[scanner scanInt:&tmp];
		self.status_ticketValue = (BOOL)tmp;
		self.status_date = [NSDate date];
	}
	self.data = nil;
	self.connection = nil;
	
	NSError * error;
	BOOL success = [self.managedObjectContext save:&error];
	if(!success)
		NSLog(@"save failed : %@ %@",error, [error userInfo]);
}

/****************************************************************************/
#pragma mark loading

- (BOOL) isLoading
{
	return nil!=self.connection;
}

+ (NSSet*) keyPathsForValuesAffectingLoading
{
	return [NSSet setWithObject:@"connection"];
}

- (NSString *) statusDescription
{
	return [NSString stringWithFormat:NSLocalizedString(@"%d vélos, %d places.",@""),self.status_availableValue, self.status_freeValue];
}

+ (NSSet*) keyPathsForValuesAffectingStatusDescription
{
	return [NSSet setWithObjects:@"status_availableValue",@"status_freeValue",nil];  
}

- (NSString *) statusDateDescription
{
	if(self.loading)
		return NSLocalizedString(@"Requête en cours",@"");
	if(nil==self.status_date)
		return NSLocalizedString(@"Aucune info",@"");

	NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.status_date];
	if(interval<60)
		return NSLocalizedString(@"à l'instant",@"");
	if(interval<90)
		return [NSString stringWithFormat:NSLocalizedString(@"il y a 1 minute",@"")];
	if(interval<60*60)
		return [NSString stringWithFormat:NSLocalizedString(@"il y a %.0f minutes",@""),interval/60.0f];
	else
		return NSLocalizedString(@"Aucune info récente",@"");
}

+ (NSSet*) keyPathsForValuesAffectingStatusDateDescription
{
	return [NSSet setWithObject:@"status_date"];
}

/****************************************************************************/
#pragma mark Location

- (CLLocation*) location
{
	if(nil==location)
		location = [[CLLocation alloc] initWithLatitude:self.latValue longitude:self.lngValue];
	return [[location retain] autorelease];
}

/****************************************************************************/
#pragma mark Clean properties

- (NSString *) cleanName
{
	NSRange range = [self.name rangeOfString:@"-"];
	if(range.location==NSNotFound)
		return self.name;
	else
		return [[self.name substringFromIndex:range.location+range.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (NSSet*) keyPathsForValuesAffectingCleanName
{
	return [NSSet setWithObjects:@"name",@"number",nil];
}

- (NSString *) cleanAddress
{
#if DEBUG
	if(![self.address hasSuffix:@" -"])
		NSLog(@"whoa ? %@ : %@",self.name, self.address);
#endif
	return [self.address stringByDeletingSuffix:@" -"];
}

+ (NSSet*) keyPathsForValuesAffectingCleanAddress
{
	return [NSSet setWithObject:@"address"];
}

/****************************************************************************/
#pragma mark Specific setters to support type coercion

- (void) setBonus:(id)value
{
	if([value isKindOfClass:[NSNumber class]])
		[super setPrimitiveValue:value forKey:@"bonus"];
	else
		[self setPrimitiveBonusValue:[value boolValue]];
}

- (void) setOpen:(id)value
{
	if([value isKindOfClass:[NSNumber class]])
		[super setPrimitiveValue:value forKey:@"open"];
	else
		[self setPrimitiveOpenValue:[value boolValue]];
}

- (void) setLat:(id)value
{
	if([value isKindOfClass:[NSNumber class]])
		[super setPrimitiveValue:value forKey:@"lat"];
	else
		[self setPrimitiveLatValue:[value doubleValue]];
}

- (void) setLng:(id)value
{
	if([value isKindOfClass:[NSNumber class]])
		[super setPrimitiveValue:value forKey:@"lng"];
	else
		[self setPrimitiveLngValue:[value doubleValue]];
}

@end
