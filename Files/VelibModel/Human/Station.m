#import "Station.h"
#import "VelibModel.h"
#import "Region.h"
#import "NSStringAdditions.h"
#import "DataUpdater.h"
#import "NSObject+KVCMapping.h"
#import "NSError+MultipleErrorsCombined.h"

/****************************************************************************/
#pragma mark -

@interface Station () <DataUpdaterDelegate, NSXMLParserDelegate>
@property (nonatomic, strong) DataUpdater * updater;
@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL loading;
@property (nonatomic, strong) NSError * updateError;
@property (nonatomic, strong) NSMutableString * currentParsedString;
@property (nonatomic, strong) CLLocation * location;
@end


/****************************************************************************/
#pragma mark -

@implementation Station

/****************************************************************************/
#pragma mark -

@synthesize updater, updateError, currentParsedString;
@synthesize refreshing, loading;
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
    self.updater = [[DataUpdater alloc] initWithDelegate:self queue:@"station"];
}

- (void) cancel
{
    [self.updater cancel];
    self.updater = nil;
    self.loading = NO;
    self.refreshing = NO;
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

- (void) updaterDidBegin:(DataUpdater *)updater
{
    self.refreshing = YES;
}

- (void) updaterDidStartRequest:(DataUpdater *)updater
{
    self.loading = YES;
}

- (void) updater:(DataUpdater *)updater didFailWithError:(NSError *)error
{
    self.updateError = error;
    self.updater = nil;
    self.refreshing = NO;
    self.loading = NO;
}

- (void) updaterDidFinishWithNoNewData:(DataUpdater *)updater
{
    self.updater = nil;
    self.refreshing = NO;
    self.loading = NO;
}

- (void) updater:(DataUpdater *)updater finishedWithNewData:(NSData *)data
{
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
    self.currentParsedString = [NSMutableString string];
	[parser parse];
    self.currentParsedString = nil;

    [self.managedObjectContext.model save:nil];
    self.updater = nil;
    self.refreshing = NO;
    self.loading = NO;
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

- (BOOL) isRefreshing
{
	return nil!=self.updater;
}

+ (NSSet*) keyPathsForValuesAffectingLoading
{
	return [NSSet setWithObject:@"updater"];
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

/****************************************************************************/
#pragma mark Delete rules

- (void) prepareForDeletion
{
    [super prepareForDeletion];
    if (self.region!=nil &&
        self.region.stations.count == 1 &&
        [self.region.stations firstObject] == self) {
        [self.managedObjectContext deleteObject:self.region];
    }
}
@end
