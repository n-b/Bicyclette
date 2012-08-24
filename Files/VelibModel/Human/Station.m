#import "Station.h"
#import "VelibModel.h"
#import "Region.h"
#import "NSStringAdditions.h"
#import "DataUpdater.h"
#import "NSObject+KVCMapping.h"
#import "NSError+MultipleErrorsCombined.h"
#if TARGET_OS_IPHONE
#import "UIApplication+LocalAlerts.h"
#endif

/****************************************************************************/
#pragma mark -

@interface Station () <DataUpdaterDelegate, NSXMLParserDelegate>
@property DataUpdater * updater;
@property BOOL loading;
@property NSError * updateError;
@property NSMutableString * currentParsedString;
@property (nonatomic) CLLocation * location;
@property BOOL notifySummary;
@end


/****************************************************************************/
#pragma mark -

@implementation Station

@synthesize updater=_updater, loading=_loading, updateError=_updateError, currentParsedString=_currentParsedString;
@synthesize isInRefreshQueue, notifySummary;
@synthesize location=_location;

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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(becomeStale) object:nil];
	if(self.updater!=nil)
		return;
    self.updateError = nil;
    self.updater = [[DataUpdater alloc] initWithDelegate:self];
}

- (void) cancel
{
    [self.updater cancel];
    self.updater = nil;
    self.loading = NO;
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

- (void) updaterDidStartRequest:(DataUpdater *)updater
{
    self.loading = YES;
}

- (void) updater:(DataUpdater *)updater didFailWithError:(NSError *)error
{
    self.updateError = error;
    self.updater = nil;
    self.loading = NO;
}

- (void) updaterDidFinishWithNoNewData:(DataUpdater *)updater
{
    self.updater = nil;
    self.loading = NO;
}

- (void) updater:(DataUpdater *)updater finishedWithNewData:(NSData *)data
{
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
    self.currentParsedString = [NSMutableString string];
	[parser parse];
    self.currentParsedString = nil;

    if(self.notifySummary)
    {
#if TARGET_OS_IPHONE
        [[UIApplication sharedApplication] presentLocalNotificationMessage:self.localizedSummary];
#endif
        self.notifySummary = NO;
    }
    
    [self.managedObjectContext.model setNeedsSave];
    self.updater = nil;
    self.loading = NO;
    
    [self performSelector:@selector(becomeStale) withObject:nil afterDelay:[[NSUserDefaults standardUserDefaults] doubleForKey:@"StationStatusStalenessInterval"]];
}

- (void) becomeStale
{
    [self willChangeValueForKey:@"statusDataIsFresh"];
    [self didChangeValueForKey:@"statusDataIsFresh"];
}

- (BOOL) statusDataIsFresh
{
    NSTimeInterval stalenessInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:@"StationStatusStalenessInterval"];
    return self.status_date && [[NSDate date] timeIntervalSinceDate:self.status_date] < stalenessInterval;
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
        s_mapping = @{
        @"available" : @"status_available",
        @"free" : @"status_free",
        @"ticket": @"status_ticket",
        @"total" : @"status_total"};
    
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
#pragma mark MKAnnotation, Locatable

- (NSString *) title
{
    return self.cleanName;
}

- (CLLocationCoordinate2D) coordinate
{
	return self.location.coordinate;
}

- (CLLocation*) location
{
	if(nil==_location)
		_location = [[CLLocation alloc] initWithLatitude:self.latitudeValue longitude:self.longitudeValue];
	return _location;
}

/****************************************************************************/
#pragma mark Display

- (NSString *) cleanName
{
    // remove number
    NSString * shortname = self.name;
    NSRange beginRange = [shortname rangeOfString:@" - "];
    if (beginRange.location!=NSNotFound)
        shortname = [self.name substringFromIndex:beginRange.location+beginRange.length];
    
    // remove city name
    NSRange endRange = [shortname rangeOfString:@"("];
    if(endRange.location!=NSNotFound)
        shortname = [shortname substringToIndex:endRange.location];
    
    // remove whitespace
    shortname = [shortname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    // capitalized
    if([shortname respondsToSelector:@selector(capitalizedStringWithLocale:)])
        shortname = [shortname capitalizedStringWithLocale:[NSLocale currentLocale]];
    else
        shortname = [shortname stringByReplacingCharactersInRange:NSMakeRange(1, shortname.length-1) withString:[[shortname substringFromIndex:1] lowercaseString]];
    
    return shortname;
}

- (NSString *) localizedSummary
{
    return [NSString stringWithFormat:NSLocalizedString(@"STATION_%@_STATUS_SUMMARY_BIKES_%d_PARKING_%d", nil),
            self.cleanName,
            self.status_availableValue, self.status_freeValue];
}

- (void) notifySummaryAfterNextRefresh
{
    self.notifySummary = YES;
}

- (void) cancelSummaryAfterNextRefresh
{
    self.notifySummary = NO;
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
                                                userInfo:@{
                             NSValidationObjectErrorKey : self,
                                NSValidationKeyErrorKey : NAMEDPROP(location),
                              NSValidationValueErrorKey : self.location,
                              NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Station %@", 0),self.name],
                       NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:NSLocalizedString(@"Invalid coordinates (%f,%f)", 0),self.location.coordinate.latitude, self.location.coordinate.longitude],
                                 }];
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

- (void) willTurnIntoFault
{
    [super willTurnIntoFault];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(becomeStale) object:nil];
}
@end
