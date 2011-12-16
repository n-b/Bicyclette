//
//  VelibModel+Favorites.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "VelibModel+Favorites.h"
#import "NSFileManager+StandardPaths.h"
#import "Station.h"
#import "BicycletteApplicationDelegate.h"
#import "List.h"
#import "Bookmark.h"

const struct VelibModelNotifications VelibModelNotifications = {
	.favoriteChanged = @"VelibModelNotificationsFavoriteChanged",
};

@implementation VelibModel (Favorites)

- (List*) mainBookmarksList
{
    NSFetchRequest * request = [NSFetchRequest new];
    request.entity = [List entityInManagedObjectContext:self.moc];
    NSError * error = nil;
    NSArray * result = [self.moc executeFetchRequest:request error:&error];
    List * list;
    if(result.count == 0)
    {
        list = [List insertInManagedObjectContext:self.moc];
        list.name = @"_favorites_";
    }
    else {
        NSAssert(result.count==1,@"There must be only one list.");
        list = [result objectAtIndex:0];
    }
    return list;
}

- (NSOrderedSet *) favoriteStations
{
    return [self.mainBookmarksList.bookmarks valueForKey:BookmarkRelationships.station];
}

@end


@implementation Station (Favorites)

/****************************************************************************/
#pragma mark Favorite

- (Bookmark*) favoriteBookmark
{
    if(self.bookmarks.count==0)
        return nil;
    NSMutableSet * bookmarks = [self.bookmarks mutableCopy];
    [bookmarks intersectSet:[self.managedObjectContext.model.mainBookmarksList.bookmarks set]];
    NSAssert(bookmarks.count==1,@"There should be 1 favorite bookmark");
    return [bookmarks anyObject];
}

- (BOOL) isFavorite
{
    return [self.managedObjectContext.model.favoriteStations containsObject:self];
}

- (void) setFavorite:(BOOL) newValue
{
    if(self.favorite!=newValue)
    {
        if(newValue)
        {
            Bookmark * bookmark = [Bookmark insertInManagedObjectContext:self.managedObjectContext];
            bookmark.list = self.managedObjectContext.model.mainBookmarksList;
            bookmark.station = self;
            [self addBookmarksObject:bookmark];  // This should not be necessary (inverse relationship of the previous line)
        }
        else
        {
            Bookmark * bookmark = self.favoriteBookmark;
            [self.managedObjectContext deleteObject:bookmark];
            [self removeBookmarksObject:bookmark]; // This should not be necessary (delete rule nullifies)
        }
        [self.managedObjectContext.model save];
        [[NSNotificationCenter defaultCenter] postNotificationName:VelibModelNotifications.favoriteChanged object:self];
    }
}

- (UIColor*) favoriteColor
{
    return self.favoriteBookmark.color;
}


@end
