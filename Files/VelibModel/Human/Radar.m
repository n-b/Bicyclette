#import "Radar.h"

@implementation Radar
@synthesize nearRadius, farRadius;
@end


@implementation Radar (MKAnnotation)
- (CLLocationCoordinate2D) coordinate
{
    return CLLocationCoordinate2DMake(self.latitudeValue, self.longitudeValue);
}

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.latitudeValue = coordinate.latitude;
    self.longitudeValue = coordinate.longitude;
}
@end
