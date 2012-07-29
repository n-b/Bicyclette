#import "_Station.h"
#import <CoreLocation/CoreLocation.h>
#import "NSMutableArray+Locatable.h"

@interface Station : _Station <MKAnnotation, Locatable>

// A flag indicating that we need to refresh the data
@property BOOL isInRefreshQueue;
@property BOOL wantsImmediateSummary;

// status
- (void) refresh;
- (void) cancel;

@property (readonly) BOOL loading;
@property (readonly) NSError * updateError;

// Computed properties
@property (nonatomic, readonly) CLLocation * location;
@property (readonly) NSString * cleanName;
@property (readonly) NSString * localizedSummary;
@end
