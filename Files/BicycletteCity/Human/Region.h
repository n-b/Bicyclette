#import "_Region.h"


#if TARGET_OS_IPHONE
@interface Region : _Region <MKAnnotation>
#else
@interface Region : _Region
#endif

- (void) setupCoordinates;

#if TARGET_OS_IPHONE
@property (readonly, nonatomic) MKCoordinateRegion coordinateRegion;
#endif

// Used for RegionAnnotationView
- (NSString*) title;
- (NSString*) subtitle;
@end
