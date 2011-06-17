#import "Station.h"
#import "VelibModel.h"
#import "Region.h"
#import "NSStringAdditions.h"
#import "DataUpdater.h"


/****************************************************************************/
#pragma mark -

NSString * const StationFavoriteDidChangeNotification = @"StationFavoriteDidChange";

@interface Station () <DataUpdaterDelegate, NSXMLParserDelegate>
@property (nonatomic, retain) DataUpdater * updater;
@property (nonatomic, retain) NSMutableString * currentParsedString;
@property (nonatomic, retain) CLLocation * location;
@end


/****************************************************************************/
#pragma mark -

@implementation Station

/****************************************************************************/
#pragma mark -

+ (NSDictionary*) kvcMapping
{
    static NSDictionary * s_mapping = nil;
    if(nil==s_mapping)
        s_mapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                     @"address",@"address",
                     @"bonus",@"bonus",
                     @"fullAddress",@"fullAddress",
                     @"latitude",@"lat",
                     @"longitude",@"lng",
                     @"name",@"name",
                     @"number",@"number",
                     @"open",@"open",
                     
                     @"available",@"status_available",
                     @"free",@"status_free",
                     @"ticket",@"status_ticket",
                     @"total",@"status_total",
                     nil];
        
    return s_mapping;
}
/****************************************************************************/
#pragma mark -

@synthesize updater, currentParsedString;
@synthesize location;

- (NSString *) description
{
	return [NSString stringWithFormat:@"Station %@ (%@): %@ (%f,%f) %s %s\n\t%s\t%02d/%02d/%02d",
			self.name, self.number, self.address, self.latitudeValue, self.longitudeValue, self.openValue?"O":"F", self.bonusValue?"+":"",
			self.status_ticketValue?"+":"", self.status_availableValue, self.status_freeValue, self.status_totalValue];
}

- (void) dealloc
{
    self.updater.delegate = nil;
    self.updater = nil;
    self.currentParsedString = nil;
	self.location = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark -

- (void) refresh
{
	if(self.updater!=nil)
		return;
    self.updater = [DataUpdater updaterWithDelegate:self];
}

- (NSTimeInterval) refreshIntervalForUpdater:(DataUpdater *)updater
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:@"StationRefreshInterval"];
}

- (NSURL*) urlForUpdater:(DataUpdater*)updater
{
    return [NSURL URLWithString:[kVelibStationsStatusURL stringByAppendingString:self.number]];
}

- (NSDate*) dataDateForUpdater:(DataUpdater*)updater
{
    return self.status_date;
}

- (void) setUpdater:(DataUpdater*)updater dataDate:(NSDate*)date
{
    self.status_date = date;
}

- (void) updaterDidFinish:(DataUpdater*)updater
{
    self.updater = nil;
}

- (void) updater:(DataUpdater *)updater receivedUpdatedData:(NSData *)data
{
    NSXMLParser * parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
	parser.delegate = self;
    self.currentParsedString = [NSMutableString string];
	[parser parse];
    self.currentParsedString = nil;

	NSError * error;
	BOOL success = [self.managedObjectContext save:&error];
	if(!success)
		NSLog(@"save failed : %@ %@",error, [error userInfo]);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.currentParsedString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString * string = [self.currentParsedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.currentParsedString = [NSMutableString string];
    if ([elementName isEqualToString:@"available"])
        self.status_availableValue = [string intValue];
    else if ([elementName isEqualToString:@"free"])
        self.status_freeValue = [string intValue];
    else if ([elementName isEqualToString:@"total"])
        self.status_totalValue = [string intValue];
    else if ([elementName isEqualToString:@"ticket"])
        self.status_ticketValue = [string boolValue];
}

/****************************************************************************/
#pragma mark loading

- (BOOL) isLoading
{
	return nil!=self.updater;
}

+ (NSSet*) keyPathsForValuesAffectingLoading
{
	return [NSSet setWithObject:@"updater"];
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
		location = [[CLLocation alloc] initWithLatitude:self.latitudeValue longitude:self.longitudeValue];
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

- (void) setLatitude:(id)value
{
	if([value isKindOfClass:[NSNumber class]])
		[super setPrimitiveValue:value forKey:@"latitude"];
	else
		[self setPrimitiveLatitudeValue:[value doubleValue]];
}

- (void) setLongitude:(id)value
{
	if([value isKindOfClass:[NSNumber class]])
		[super setPrimitiveValue:value forKey:@"longitude"];
	else
		[self setPrimitiveLongitudeValue:[value doubleValue]];
}

@end
