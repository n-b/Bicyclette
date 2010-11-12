#import "Section.h"
@implementation Section

- (NSString *) description
{
	return [NSString stringWithFormat:@"Section %@ (%d stations)",self.name, self.stations.count];
}

@end
