#import "_Radar.h"

#if TARGET_OS_IPHONE
#import "GeoFencesMonitor.h"
#import "LocalUpdateQueue.h"

@interface Radar : _Radar <MKAnnotation, GeoFence, LocalUpdateGroup>

// A square of size specified in the prefs, centered at the coordinate of the Radar
@property (nonatomic,readonly) MKCoordinateRegion radarRegion;

@end

#endif
