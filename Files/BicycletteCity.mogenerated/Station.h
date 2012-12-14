#import "_Station.h"
#import "LocalUpdateQueue.h"

@interface Station : _Station < Locatable
#if TARGET_OS_IPHONE
								,MKAnnotation
#endif
								>

- (CLLocation *) location;

- (NSString *) localizedSummary;

@end
