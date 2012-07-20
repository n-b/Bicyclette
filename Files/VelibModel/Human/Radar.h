#import "_Radar.h"
#import "NSMutableArray+Locatable.h"


@interface Radar : _Radar <MKAnnotation, Locatable>
// A square of size specified in the prefs, centered at the coordinate of the Radar
@property (nonatomic,readonly) MKCoordinateRegion radarRegion;
// The stations nearer than the distance specified in the prefs, sorted from nearest to farthest.
@property (nonatomic,readonly) NSArray * stationsWithinRadarRegion;

@end


// Static Radar Identifiers
extern const struct RadarIdentifiers {
	__unsafe_unretained NSString *userLocation;
	__unsafe_unretained NSString *screenCenter;
} RadarIdentifiers;
