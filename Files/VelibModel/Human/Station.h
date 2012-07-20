#import "_Station.h"
#import <CoreLocation/CoreLocation.h>
#import "NSMutableArray+Locatable.h"

@interface Station : _Station <MKAnnotation, Locatable>

// status
- (void) refresh;
- (void) cancel;

@property (nonatomic, readonly) BOOL loading;
@property (nonatomic, readonly, strong) NSError * updateError;

@property BOOL needsRefresh;

// Computed properties
@property (weak, nonatomic, readonly) NSString * cleanName;
@property (nonatomic, strong, readonly) CLLocation * location;

@end
