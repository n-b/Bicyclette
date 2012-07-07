#import "_Radar.h"


extern const struct RadarIdentifiers {
	__unsafe_unretained NSString *userLocation;
	__unsafe_unretained NSString *screenCenter;
} RadarIdentifiers;

@interface Radar : _Radar
// A square of size specified in the prefs, centered at the coordinate of the Radar
@property (nonatomic,readonly) MKCoordinateRegion radarRegion;
// The stations nearer than the distance specified in the prefs, sorted from nearest to farthest.
@property (nonatomic,readonly) NSArray * stationsWithinRadarRegion;
@end


@interface Radar (MKAnnotation) <MKAnnotation>
@property CLLocationCoordinate2D coordinate;

@end
