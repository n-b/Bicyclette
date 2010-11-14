#import "_Station.h"
#import <CoreLocation/CoreLocation.h>

@interface Station : _Station {}
- (void) refresh;
- (void) setupCodePostal;
- (void) save;

@property (nonatomic, getter=isFavorite) BOOL favorite;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, retain, readonly) CLLocation * location;
@end
