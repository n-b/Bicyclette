#import "_Station.h"
#import "LocalUpdateQueue.h"

@interface Station : _Station < LocalUpdatePoint
#if TARGET_OS_IPHONE
								,MKAnnotation >
#else
								>
#endif

// status
- (void) cancel;

@property (readonly) BOOL updating;

// Computed properties
@property (readonly) CLLocation * location;
@property (readonly) NSString * localizedSummary;

// whether the data is not too old
@property (readonly) BOOL statusDataIsFresh;
@end
