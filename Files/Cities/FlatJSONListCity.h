//
//  FlatJSONListCity.h
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "FlatListCity.h"

// JSON
@interface FlatJSONListCity : FlatListCity
- (NSArray*) stationAttributesArraysFromData:(NSData*)data; // basic JSON deserialize
- (NSString*) keyPathToStationsLists; // override if necessary
@end

