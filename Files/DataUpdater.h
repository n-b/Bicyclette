//
//  DataUpdater.h
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Visuamobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataUpdaterDelegate;

/****************************************************************************/
#pragma mark -

// Data Update generic machinery
@interface DataUpdater : NSObject

+ (id) updaterWithDelegate:(id<DataUpdaterDelegate>) delegate;
- (id) initWithDelegate:(id<DataUpdaterDelegate>) delegate;

@property (nonatomic, assign) id<DataUpdaterDelegate> delegate;

@property (readonly) BOOL downloadingUpdate;

@end

/****************************************************************************/
#pragma mark -

@protocol DataUpdaterDelegate <NSObject>
- (NSURL*) urlForUpdater:(DataUpdater*)updater;
- (void) updater:(DataUpdater*)updater finishedReceivingData:(NSData*)data;
@end