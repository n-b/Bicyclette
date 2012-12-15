#if TARGET_OS_IPHONE

#import "Radar.h"
#import "Station.h"
#import "LocalUpdateQueue.h"
#import "BicycletteCity.h"


@interface Radar()
@property NSArray* pointsToUpdate;
@end

@implementation Radar
@synthesize pointsToUpdate;

- (void) awakeFromFetch
{
    [super awakeFromFetch];
    [self startObserving];
    [self updateStationsInRadar];
}

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    [self startObserving];
}

- (void) willTurnIntoFault
{
    [super willTurnIntoFault];
    [self stopObserving];
}

/****************************************************************************/
#pragma mark KVO

- (void) startObserving
{
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"RadarDistance" options:0 context:(__bridge void *)([Radar class])];
}

- (void) stopObserving
{
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"RadarDistance" context:(__bridge void *)([Radar class])];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([Radar class])) {
        [self willChangeValueForKey:@"radarRegion"];
        [self willChangeValueForKey:@"fenceRegion"];
        [self didChangeValueForKey:@"radarRegion"];
        [self didChangeValueForKey:@"fenceRegion"];
        [self updateStationsInRadar];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/****************************************************************************/
#pragma mark GeoFence

- (CLRegion*) fenceRegion
{
    CLLocationDistance radarDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadarDistance"];
    CLLocationDistance monitorDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"MonitorDistance"];
    return [[CLRegion alloc] initCircularRegionWithCenter:self.coordinate radius:radarDistance+monitorDistance identifier:self.identifier];
}

+ (NSSet *)keyPathsForValuesAffectingFenceRegion
{
    return [NSSet setWithObject:@"coordinate"];
}

/****************************************************************************/
#pragma mark Locatable

- (CLLocation *) location
{
    return [[CLLocation alloc] initWithLatitude:self.latitudeValue longitude:self.longitudeValue];
}

+ (NSSet *)keyPathsForValuesAffectingLocation
{
    return [NSSet setWithObjects:@"latitude", @"longitude",nil];
}

/****************************************************************************/
#pragma mark LocalUpdateGroup

- (void) updateStationsInRadar
{
    // Fetch in a square
    MKCoordinateRegion region = [self radarRegion];
    NSArray * stations = [self.city stationsWithinRegion:region];

    // Sort from center
    stations = [stations sortedArrayByDistanceFromLocation:[[CLLocation alloc]initWithLatitude:region.center.latitude longitude:region.center.longitude]];

    // chop those that are in the square, but actually farther that the radar distance
    CLLocationDistance radarDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadarDistance"];
    stations = [stations filteredArrayWithinDistance:radarDistance fromLocation:self.location];

    self.pointsToUpdate = stations;
}

/****************************************************************************/
#pragma mark -

- (MKCoordinateRegion) radarRegion
{
    CLLocationDistance radarDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadarDistance"];
    return MKCoordinateRegionMakeWithDistance(self.coordinate, radarDistance*2, radarDistance*2);
}

+ (NSSet *)keyPathsForValuesAffectingRadarRegion
{
    return [NSSet setWithObject:@"coordinate"];
}

/****************************************************************************/
#pragma mark Location / Coordinate

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
        [self updateStationsInRadar];
    }
}

@end

#endif
