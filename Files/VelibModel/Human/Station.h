#import "_Station.h"
#import <CoreLocation/CoreLocation.h>

@interface Station : _Station {}

// status
- (void) refresh;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly, strong) NSError * updateError;

// Computed properties
@property (weak, nonatomic, readonly) NSString * cleanName;
@property (nonatomic, strong, readonly) CLLocation * location;

@end
