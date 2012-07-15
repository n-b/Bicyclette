//
//  UpdaterQueue.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 16/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataUpdater;

@interface UpdaterQueue : NSObject
+ (id)queueWithName:(NSString*)name;
- (void) startUpdater:(DataUpdater*)updater;
- (void) cancelUpdater:(DataUpdater*)updater;

@end
