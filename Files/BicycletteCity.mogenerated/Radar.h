#import "_Radar.h"
#import "NSMutableArray+Locatable.h"

#if TARGET_OS_IPHONE

@interface Radar : _Radar <MKAnnotation>
// A square of size specified in the prefs, centered at the coordinate of the Radar
@property (nonatomic,readonly) MKCoordinateRegion radarRegion;
// The stations nearer than the distance specified in the prefs, sorted from nearest to farthest.
@property (nonatomic,readonly) NSArray * stationsWithinRadarRegion;
// A circular region centered at the Radar location
@property (nonatomic,readonly) CLRegion* monitoringRegion;

- (void) setWantsSummary;
- (void) clearWantsSummary;
@property (readonly) BOOL wantsSummary;
@end


// Static Radar Identifiers
extern const struct RadarIdentifiers {
	__unsafe_unretained NSString *userLocation;
	__unsafe_unretained NSString *screenCenter;
} RadarIdentifiers;

#endif
