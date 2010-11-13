#import "_Station.h"

@interface Station : _Station {}
- (void) refresh;
- (void) setupCodePostal;
- (void) save;

@property (nonatomic) BOOL favorite;
@end
