#import "List.h"
#import "Bookmark.h"
#import "Station.h"

@implementation List

- (NSOrderedSet*) stations
{
    NSString * keypath = [NSString stringWithFormat:@"%@.%@",ListRelationships.bookmarks, BookmarkRelationships.station];
    return [self valueForKeyPath:keypath];
}

+ (NSSet *)keyPathsForValuesAffectingStations
{
	return [NSSet setWithObject:[NSString stringWithFormat:@"%@.%@",ListRelationships.bookmarks, BookmarkRelationships.station]];
}

@end
