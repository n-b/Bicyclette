#import "Station.h"
#import "VelibModel.h"
#import "Region.h"
#import "NSStringAdditions.h"
#import "DataUpdater.h"
#import "NSObject+KVCMapping.h"
#import "NSError+MultipleErrorsCombined.h"

/****************************************************************************/
#pragma mark -

NSString * const StationFavoriteDidChangeNotification = @"StationFavoriteDidChange";

@interface Station () <DataUpdaterDelegate, NSXMLParserDelegate>
@property (nonatomic, strong) DataUpdater * updater;
@property (nonatomic, strong) NSError * updateError;
@property (nonatomic, strong) NSMutableString * currentParsedString;
@property (nonatomic, strong) CLLocation * location;
- (BOOL)validateConsistency:(NSError **)error;
@end


/****************************************************************************/
#pragma mark -

@implementation Station

/****************************************************************************/
#pragma mark -

@synthesize updater, updateError, currentParsedString;
@synthesize location;

- (NSString *) debugDescription
{
	return [NSString stringWithFormat:@"Station %@ (%@): %@ (%f,%f) %s %s\n\t%s\t%02d/%02d/%02d",
			self.name, self.number, self.address, self.latitudeValue, self.longitudeValue, self.openValue?"O":"F", self.bonusValue?"+":"",
			self.status_ticketValue?"+":"", self.status_availableValue, self.status_freeValue, self.status_totalValue];
}

- (void) dealloc
{
    self.updater.delegate = nil;
}

/****************************************************************************/
#pragma mark updating

- (void) refresh
{
	if(self.updater!=nil)
		return;
    self.updateError = nil;
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

- (void) updater:(DataUpdater *)updater didFailWithError:(NSError *)error
{
    self.updateError = error;
    self.updater = nil;
}

- (void) updater:(DataUpdater *)updater receivedUpdatedData:(NSData *)data
{
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
    self.currentParsedString = [NSMutableString string];
	[parser parse];
    self.currentParsedString = nil;

    [self.managedObjectContext.model save];
}

/****************************************************************************/
#pragma mark parsing

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.currentParsedString appendString:string];
}

- (NSDictionary*) stationStatusKVCMapping
{
    static NSDictionary * s_mapping = nil;
    if(nil==s_mapping)
        s_mapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                     @"status_available",@"available",
                     @"status_free",@"free",
                     @"status_ticket",@"ticket",
                     @"status_total",@"total",
                     nil];
    
    return s_mapping;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString * value = [self.currentParsedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.currentParsedString = [NSMutableString string];
    if([value length])
        [self setValue:value forKey:elementName withMappingDictionary:self.stationStatusKVCMapping];
}

/****************************************************************************/
#pragma mark status

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
	return location;
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
#pragma mark Validation

- (BOOL)validateForInsert:(NSError **)error
{
    BOOL propertiesValid = [super validateForInsert:error];
    // could stop here if invalid
    BOOL consistencyValid = [self validateConsistency:error];
    return (propertiesValid && consistencyValid);
}

- (BOOL)validateForUpdate:(NSError **)error
{
    BOOL propertiesValid = [super validateForUpdate:error];
    // could stop here if invalid
    BOOL consistencyValid = [self validateConsistency:error];
    return (propertiesValid && consistencyValid);
}

- (BOOL)validateConsistency:(NSError **)error
{
    if([self.managedObjectContext.model.hardcodedLimits containsCoordinate:self.location.coordinate])
        return YES;

    if (error != NULL) {
        NSError * limitsError = [NSError errorWithDomain:BicycletteErrorDomain
                                                    code:NSManagedObjectValidationError
                                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          self, NSValidationObjectErrorKey,
                                                          NAMEDPROP(location), NSValidationKeyErrorKey,
                                                          self.location, NSValidationValueErrorKey,
                                                          [NSString stringWithFormat:NSLocalizedString(@"Station %@", 0),self.name],NSLocalizedDescriptionKey,
                                                          [NSString stringWithFormat:NSLocalizedString(@"Invalid coordinates (%f,%f)", 0),self.location.coordinate.latitude, self.location.coordinate.longitude], NSLocalizedFailureReasonErrorKey,
                                                          nil]];
        *error = [NSError errorFromOriginalError:*error error:limitsError];
    }
    return NO;
}

@end
