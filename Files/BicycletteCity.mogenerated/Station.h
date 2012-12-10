#import "_Station.h"

#if TARGET_OS_IPHONE
@interface Station : _Station <MKAnnotation>
#else
@interface Station : _Station
#endif

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
@property (readonly) NSString * localizedSummary;

// whether the data is not too old
@property (readonly) BOOL statusDataIsFresh;
@end
