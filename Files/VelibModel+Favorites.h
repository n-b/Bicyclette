//
//  VelibModel+Favorites.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "VelibModel.h"
#import "Station.h"

@class List;

@interface VelibModel (Favorites)
@property (nonatomic, readonly) List* mainBookmarksList;
@end

@interface Station (Favorites)
@property (nonatomic, getter=isFavorite) BOOL favorite;
@end

// Notification
extern const struct VelibModelNotifications {
	__unsafe_unretained NSString *favoriteChanged;
} VelibModelNotifications;
