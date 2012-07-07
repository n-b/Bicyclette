#import "Radar.h"
#import "Station.h"
#import "NSMutableArray+Stations.h"

const struct RadarIdentifiers RadarIdentifiers = {
	.userLocation = @"userLocationRadar",
	.screenCenter = @"screenCenterRadar",
};


@interface Radar()
@property (nonatomic) NSArray * stationsWithinRange;
@end

@implementation Radar
@synthesize stationsWithinRange=_stationsWithinRange;

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
    if (_stationsWithinRange==nil)
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
        [stations filterStationsWithinDistance:radarDistance fromLocation:location];
        [stations sortStationsNearestFirstFromLocation:location];
        _stationsWithinRange = [stations copy];
    }
    return _stationsWithinRange;
}
@end


@implementation Radar (MKAnnotation)
- (CLLocationCoordinate2D) coordinate
{
    return CLLocationCoordinate2DMake(self.latitudeValue, self.longitudeValue);
}

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.stationsWithinRange = nil;
    self.latitudeValue = coordinate.latitude;
    self.longitudeValue = coordinate.longitude;
}
@end
