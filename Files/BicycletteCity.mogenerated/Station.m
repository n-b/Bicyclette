#import "Station.h"
#import "BicycletteCity.h"
#import "NSStringAdditions.h"
#import "NSError+MultipleErrorsCombined.h"

@implementation Station
{
    CLLocationCoordinate2D _coordinate;
    BOOL _coordinateCached;
    CLLocation * _location;
}
- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

/****************************************************************************/
#pragma mark MKAnnotation, Locatable

- (NSString *) title
{
    return [[self city] titleForStation:self];
}

- (NSString *) subtitle
{
    return [[self city] subtitleForStation:self];
}

- (CLLocationCoordinate2D) coordinate
{
    if(!_coordinateCached) {
        _coordinate = CLLocationCoordinate2DMake(self.latitudeValue, self.longitudeValue);
        _coordinateCached = YES;
    }
	return _coordinate;
}

- (CLLocation*) location
{
    if(!_location){
        _location = [[CLLocation alloc] initWithLatitude:self.latitudeValue longitude:self.longitudeValue];
    }
    return _location;
}

- (void)didSave
{
    [super didSave];
    _location = nil;
    _coordinateCached = NO;
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
    CLCircularRegion * knownRegion = self.city.knownRegion;
    CLLocation * center = [[CLLocation alloc] initWithLatitude:knownRegion.center.latitude longitude:knownRegion.center.longitude];
    if([center distanceFromLocation:self.location] < knownRegion.radius * 1.5 || knownRegion.radius==0)
        return YES;

    if (error != NULL) {
        NSError * limitsError = [NSError errorWithDomain: NSCocoaErrorDomain
                                                    code: NSManagedObjectValidationError
                                                userInfo:@{
                             NSValidationObjectErrorKey : self,
                                NSValidationKeyErrorKey : @"location",
                              NSValidationValueErrorKey : self.location,
                              NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Station %@ (%@)", 0), self.number, self.name],
                       NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:NSLocalizedString(@"Invalid coordinates (%f, %f)", 0),self.location.coordinate.latitude, self.location.coordinate.longitude],
                                 }];
        *error = [NSError errorFromOriginalError:*error error:limitsError];
    }
    return NO;
}

@end
