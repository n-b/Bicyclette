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



@interface VelibModel (FavoritesPrivate)
@property (nonatomic, copy) NSArray * favoritesIdentifiers;
@property (nonatomic, readonly) NSString * favoritesFilePath;

@end

@implementation VelibModel (Favorites)

- (NSArray *) favorites
{
    NSArray * identifiers = self.favoritesIdentifiers;
    NSFetchRequest * request = [[NSFetchRequest new] autorelease];
    request.entity = [Station entityInManagedObjectContext:self.moc];
    request.predicate = [NSPredicate predicateWithFormat:@"number IN %@", identifiers];
    
    NSError * error = nil;
    NSArray * result = [self.moc executeFetchRequest:request error:&error];
    result = [result sortedArrayUsingComparator:^( id a, id b ) {
        NSUInteger indexA = [identifiers indexOfObject:a];
        NSUInteger indexB = [identifiers indexOfObject:b];
        return indexA<indexB?NSOrderedAscending:indexA>indexB?NSOrderedDescending:NSOrderedSame;
    }];
    
    return result;
}

- (void) setFavorites:(NSArray *)favorites
{
    self.favoritesIdentifiers = [favorites valueForKey:@"number"];
}

- (NSArray *) favoritesIdentifiers
{
    NSArray * favs = [NSArray arrayWithContentsOfFile:self.favoritesFilePath];
    if(nil==favs)
    {
        favs = [NSArray array];
        self.favoritesIdentifiers = favs;
    }
    return favs;
}

- (void) setFavoritesIdentifiers:(NSArray*)identifiers
{
    [identifiers writeToFile:self.favoritesFilePath atomically:YES];
}

- (NSString*) favoritesFilePath
{
    return [[NSFileManager documentsDirectory] stringByAppendingPathComponent:@"favorites.plist"];
}

@end


@implementation Station (Favorites)

/****************************************************************************/
#pragma mark Favorite

- (void) setFavorite:(BOOL) newValue
{
    if(self.favorite!=newValue)
    {
        NSMutableArray * favs = [NSMutableArray arrayWithArray:BicycletteAppDelegate.model.favoritesIdentifiers];
        if(newValue)
            [favs addObject:self.number];
        else
            [favs removeObject:self.number];
        BicycletteAppDelegate.model.favoritesIdentifiers = favs;
        [[NSNotificationCenter defaultCenter] postNotificationName:StationFavoriteDidChangeNotification object:self];
    }
}

- (BOOL) isFavorite
{
	return [BicycletteAppDelegate.model.favoritesIdentifiers containsObject:self.number];
}


@end