#import "_Station.h"
#import <CoreLocation/CoreLocation.h>

@interface Station : _Station {}

// setup
- (BOOL) setupCodePostal;
- (void) save;

// status
- (void) refresh;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

// Computed properties
@property (nonatomic, readonly) NSString * cleanName;
@property (nonatomic, readonly) NSString * cleanAddress;
@property (nonatomic, readonly) NSString * statusDescription;
@property (nonatomic, readonly) NSString * statusDateDescription;
@property (nonatomic, retain, readonly) CLLocation * location;

@end


// Notification

extern NSString * const StationFavoriteDidChangeNotification;