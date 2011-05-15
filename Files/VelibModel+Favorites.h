//
//  VelibModel+Favorites.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "VelibModel.h"
#import "Station.h"

@interface VelibModel (Favorites)
@property (nonatomic, assign) NSArray * favorites;
@end

@interface Station (Favorites)
// Favorite
@property (nonatomic, getter=isFavorite) BOOL favorite;
@end