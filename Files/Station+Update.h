//
//  Station+Update.h
//  Bicyclette
//
//  Created by Nicolas on 14/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "Station.h"

#pragma mark -
@interface Station (Update) <LocalUpdatePoint>
@property (readonly) BOOL updating;
@property (readonly) BOOL statusDataIsFresh;
@end

extern NSString * const StationStatusDidBecomeStaleNotificiation;
