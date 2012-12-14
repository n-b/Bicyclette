//
//  DataUpdater.h
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataUpdaterDelegate;

// Data Update generic machinery
@interface DataUpdater : NSObject

- (id) initWithURLStrings:(NSArray*)urlStrings delegate:(id<DataUpdaterDelegate>)delegate;
@property (nonatomic, weak) id<DataUpdaterDelegate> delegate;

- (void) cancel;

@end

/****************************************************************************/
#pragma mark -

@protocol DataUpdaterDelegate <NSObject>
- (void) updater:(DataUpdater*)updater didFailWithError:(NSError*)error;
- (void) updaterDidFinishWithNoNewData:(DataUpdater*)updater;
- (void) updater:(DataUpdater*)updater finishedWithNewDataChunks:(NSDictionary*)datas;
@end
