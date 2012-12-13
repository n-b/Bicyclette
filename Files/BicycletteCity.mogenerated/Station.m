#import "Station.h"
#import "BicycletteCity.h"
#import "Region.h"
#import "NSStringAdditions.h"
#import "DataUpdater.h"
#import "NSObject+KVCMapping.h"
#import "NSError+MultipleErrorsCombined.h"

/****************************************************************************/
#pragma mark -

@interface Station () <DataUpdaterDelegate, NSXMLParserDelegate>
@property DataUpdater * updater;
@property BOOL updating;
@property NSMutableString * currentParsedString;
@property (copy) void(^completionBlock)(NSError*) ;
@end


/****************************************************************************/
#pragma mark -

@implementation Station

@synthesize updater, updating, currentParsedString, completionBlock;
@synthesize queuedForUpdate;

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

- (void) updateWithCompletionBlock:(void (^)(NSError* error))completion
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(becomeStale) object:nil];
	if(self.updater!=nil)
		return;
    self.completionBlock = completion;
    self.updater = [[DataUpdater alloc] initWithURLStrings:@[[[self city] detailsURLStringForStation:self]]
                                                  delegate:self];
}

- (void) cancel
{
    [self.updater cancel];
    self.updater = nil;
    self.updating = NO;
    self.completionBlock = nil;
}

- (void) updaterDidStartRequest:(DataUpdater *)updater
{
    self.updating = YES;
}

- (void) updater:(DataUpdater *)updater didFailWithError:(NSError *)error
{
    self.updater = nil;
    self.updating = NO;
    if (completionBlock)
        self.completionBlock(error);
    self.completionBlock = nil;
}

- (void) updaterDidFinishWithNoNewData:(DataUpdater *)updater
{
    self.updater = nil;
    self.updating = NO;
    if (completionBlock)
        self.completionBlock(nil);
    self.completionBlock = nil;
}

- (void) updater:(DataUpdater *)updater finishedWithNewDataChunks:(NSDictionary *)datas
{
    [self.city performUpdates:^(NSManagedObjectContext *updateContext) {
        Station * station = (Station*)[updateContext objectWithID:self.objectID];
        NSXMLParser * parser = [[NSXMLParser alloc] initWithData:[[datas allValues] lastObject]];
        parser.delegate = station;
        station.currentParsedString = [NSMutableString string];
        [parser parse];
        station.currentParsedString = nil;
        station.status_date = [NSDate date];
    } saveCompletion:^(NSNotification *contextDidSaveNotification) {
        NSAssert([[[contextDidSaveNotification.userInfo[NSUpdatedObjectsKey] anyObject] objectID] isEqual:[self objectID]], nil);
        self.updater = nil;
        self.updating = NO;
        if(self.completionBlock)
            self.completionBlock(nil);
        self.completionBlock = nil;
    }];
    

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
    return [[self city] titleForStation:self];
}

- (CLLocationCoordinate2D) coordinate
{
	return self.location.coordinate;
}

- (CLLocation*) location
{
    return [[CLLocation alloc] initWithLatitude:self.latitudeValue longitude:self.longitudeValue];
}

/****************************************************************************/
#pragma mark Display

- (NSString *) localizedSummary
{
    return [NSString stringWithFormat:NSLocalizedString(@"STATION_%@_STATUS_SUMMARY_BIKES_%d_PARKING_%d", nil),
            self.title,
            self.status_availableValue, self.status_freeValue];
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
    if([[self city].hardcodedLimits containsCoordinate:self.location.coordinate])
        return YES;

    if (error != NULL) {
        NSError * limitsError = [NSError errorWithDomain: NSCocoaErrorDomain
                                                    code: NSManagedObjectValidationError
                                                userInfo:@{
                             NSValidationObjectErrorKey : self,
                                NSValidationKeyErrorKey : @"location",
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
