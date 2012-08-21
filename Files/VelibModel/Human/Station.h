#import "_Station.h"
#import <CoreLocation/CoreLocation.h>
#import "NSMutableArray+Locatable.h"

@interface Station : _Station <MKAnnotation, Locatable>

// A flag indicating that we need to refresh the data
@property BOOL isInRefreshQueue;

// Summary notification
- (void) notifySummaryAfterNextRefresh;
- (void) cancelSummaryAfterNextRefresh;

// status
- (void) refresh;
- (void) cancel;

@property (readonly) BOOL loading;
@property (readonly) NSError * updateError;

// Computed properties
@property (nonatomic, readonly) CLLocation * location;
@property (readonly) NSString * cleanName;
@property (readonly) NSString * localizedSummary;

// whether the data is not too old
@property (readonly) BOOL statusDataIsFresh;
@end
