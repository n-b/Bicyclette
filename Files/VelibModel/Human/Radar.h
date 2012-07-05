#import "_Radar.h"



@interface Radar : _Radar
@property CGFloat nearRadius, farRadius;
@end


@interface Radar (MKAnnotation) <MKAnnotation>
@property CLLocationCoordinate2D coordinate;
@end
