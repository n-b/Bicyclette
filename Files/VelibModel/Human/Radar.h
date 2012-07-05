#import "_Radar.h"



@interface Radar : _Radar
@property (nonatomic,readonly) MKCoordinateRegion radarRegion;
@property (nonatomic,readonly) NSArray * stationsWithinRadarRegion;
@end


@interface Radar (MKAnnotation) <MKAnnotation>
@property CLLocationCoordinate2D coordinate;

@end
