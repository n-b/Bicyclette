#import "Station.h"
#import "NSStringAdditions.h"

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


@interface Station () 
@property (nonatomic, retain) NSURLConnection * connection;
@property (nonatomic, retain) NSMutableData * data;
@end


/****************************************************************************/
#pragma mark -

@implementation Station

@synthesize data,connection;

- (NSString *) description
{
	return [NSString stringWithFormat:@"Station %@ (%@): %@ (%f,%f) %s %s\n\t%s\t%02d/%02d/%02d",
			self.name, self.number, self.address, self.latValue, self.lngValue, self.openValue?"O":"F", self.bonusValue?"+":"",
			self.status_ticketValue?"+":"", self.status_availableValue, self.status_freeValue, self.status_totalValue];
}

- (void) setupCodePostal
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
	self.code_postal = codePostal;	
}


- (void) refresh
{
	if(self.connection!=nil)
	{
		NSLog(@"requete déjà en cours %@",self.number);
		return;
	}
	if([self.refresh_date timeIntervalSinceNow] < -5)
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
		self.status_availableValue = tmp;
		[scanner scanUpToString:@"<free>" intoString:NULL];
		[scanner scanString:@"<free>" intoString:NULL];
		[scanner scanInt:&tmp];
		self.status_freeValue = tmp;
		[scanner scanUpToString:@"<total>" intoString:NULL];
		[scanner scanString:@"<total>" intoString:NULL];
		[scanner scanInt:&tmp];
		self.status_totalValue = tmp;
		[scanner scanUpToString:@"<ticket>" intoString:NULL];
		[scanner scanString:@"<ticket>" intoString:NULL];
		[scanner scanInt:&tmp];
		self.status_ticketValue = tmp;
		self.refresh_date = [NSDate date];
	}
	self.data = nil;
	self.connection = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StationUpdated" object:self];
	
	NSError * saveError = nil;
	[self.managedObjectContext save:&saveError];
	if(saveError)
		NSLog(@"Save error : %@ %@",[saveError localizedDescription], [saveError userInfo]);
	
}

@end
