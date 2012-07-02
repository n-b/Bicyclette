#import "_Station.h"
#import <CoreLocation/CoreLocation.h>

@interface Station : _Station {}

// status
- (void) refresh;
- (void) cancel;
@property (nonatomic, readonly) BOOL refreshing;
@property (nonatomic, readonly) BOOL loading;
@property (nonatomic, readonly, strong) NSError * updateError;

// Computed properties
@property (weak, nonatomic, readonly) NSString * cleanName;
@property (nonatomic, strong, readonly) CLLocation * location;

@end
