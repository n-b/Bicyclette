#import "_Station.h"
#import <CoreLocation/CoreLocation.h>

@interface Station : _Station {}

// status
- (void) refresh;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

// Computed properties
@property (weak, nonatomic, readonly) NSString * cleanName;
@property (weak, nonatomic, readonly) NSString * cleanAddress;
@property (weak, nonatomic, readonly) NSString * statusDescription;
@property (weak, nonatomic, readonly) NSString * statusDateDescription;
@property (nonatomic, strong, readonly) CLLocation * location;

@end


// Notification

extern NSString * const StationFavoriteDidChangeNotification;