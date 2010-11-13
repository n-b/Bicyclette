#import "_Station.h"

@interface Station : _Station {}
- (void) refresh;
- (void) setupCodePostal;

@property (nonatomic) BOOL favorite;
@end
