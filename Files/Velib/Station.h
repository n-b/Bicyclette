#import "_Station.h"
#import <CoreLocation/CoreLocation.h>

@interface Station : _Station {}
- (void) refresh;
- (void) setupCodePostal;
- (void) save;

@property (nonatomic) BOOL favorite;

@property (nonatomic, retain, readonly) CLLocation * location;
@end
