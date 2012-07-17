#import "Radar.h"
#import "Station.h"
#import "NSMutableArray+Locatable.h"

const struct RadarIdentifiers RadarIdentifiers = {
	.userLocation = @"userLocationRadar",
	.screenCenter = @"screenCenterRadar",
};


@interface Radar()
@property (nonatomic) NSArray * stationsWithinRadarRegion;
@end

@implementation Radar
@synthesize stationsWithinRadarRegion=_stationsWithinRadarRegion;

- (MKCoordinateRegion) radarRegion
{
    CLLocationDistance radarDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadarDistance"];
    return MKCoordinateRegionMakeWithDistance(self.coordinate, radarDistance*2, radarDistance*2);
}

+ (NSSet *)keyPathsForValuesAffectingRadarRegion
{
    return [NSSet setWithObject:@"coordinate"];
}

- (NSArray *) stationsWithinRadarRegion
{
    if(_stationsWithinRadarRegion == nil)
        [self updateStationsWithinRadarRegion];

    return _stationsWithinRadarRegion;
}

- (void) updateStationsWithinRadarRegion
{
    // Fetch in a square
    MKCoordinateRegion region = [self radarRegion];
    NSMutableArray * stations = [[Station fetchStationsWithinRange:self.managedObjectContext
                                                       minLatitude:@(region.center.latitude - region.span.latitudeDelta/2)
                                                       maxLatitude:@(region.center.latitude + region.span.latitudeDelta/2)
                                                      minLongitude:@(region.center.longitude - region.span.longitudeDelta/2)
                                                      maxLongitude:@(region.center.longitude + region.span.longitudeDelta/2)] mutableCopy];
    
    // chop those that are actually farther
    CLLocationDistance radarDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadarDistance"];
    CLLocation * location = [[CLLocation alloc] initWithLatitude:self.latitudeValue longitude:self.longitudeValue];
    [stations filterWithinDistance:radarDistance fromLocation:location];
    [stations sortByDistanceFromLocation:location];
    self.stationsWithinRadarRegion = [stations copy];
}

- (CLLocation*) location
{
    return [[CLLocation alloc] initWithLatitude:self.latitudeValue longitude:self.longitudeValue];
}

@end


@implementation Radar (MKAnnotation)
- (CLLocationCoordinate2D) coordinate
{
    return CLLocationCoordinate2DMake(self.latitudeValue, self.longitudeValue);
}

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate
{
    if(self.latitudeValue!=coordinate.latitude || self.longitudeValue != coordinate.longitude)
    {
        self.latitudeValue = coordinate.latitude;
        self.longitudeValue = coordinate.longitude;
        [self updateStationsWithinRadarRegion];
    }
}
@end
