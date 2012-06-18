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
#import "StationList.h"

@implementation VelibModel (Favorites)

- (StationList*) mainBookmarksList
{
    NSFetchRequest * request = [NSFetchRequest new];
    request.entity = [StationList entityInManagedObjectContext:self.moc];
    request.includesSubentities = NO;
    NSError * error = nil;
    NSArray * result = [self.moc executeFetchRequest:request error:&error];
    StationList * list;
    if(result.count == 0)
    {
        list = [StationList insertInManagedObjectContext:self.moc];
    }
    else {
        NSAssert(result.count==1,@"There must be only one list.");
        list = [result objectAtIndex:0];
    }
    return list;
}

@end


@implementation Station (Favorites)

/****************************************************************************/
#pragma mark Favorite

- (BOOL) isFavorite
{
    return [self.managedObjectContext.model.mainBookmarksList.stations containsObject:self];
}

- (void) setFavorite:(BOOL) newValue
{
    if(self.favorite!=newValue)
    {
        if(newValue)
            [self.managedObjectContext.model.mainBookmarksList.stationsSet addObject:self];
        else
            [self.managedObjectContext.model.mainBookmarksList.stationsSet removeObject:self];

        [self.managedObjectContext.model save:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VelibModelNotifications.favoriteChanged object:self];
    }
}

@end
