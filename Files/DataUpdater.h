//
//  DataUpdater.h
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Visuamobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataUpdaterDelegate;

// Data Update generic machinery
@interface DataUpdater : NSObject

- (id) initWithDelegate:(id<DataUpdaterDelegate>)delegate;

@property (nonatomic, weak) id<DataUpdaterDelegate> delegate;

- (void) startRequest;
- (void) cancel;

@end

/****************************************************************************/
#pragma mark -

@protocol DataUpdaterDelegate <NSObject>
- (void) updaterDidStartRequest:(DataUpdater*)updater;
- (void) updater:(DataUpdater*)updater didFailWithError:(NSError*)error;
- (void) updaterDidFinishWithNoNewData:(DataUpdater*)updater;
- (void) updater:(DataUpdater*)updater finishedWithNewData:(NSData*)data;

// Data for updater
- (NSURL*) urlForUpdater:(DataUpdater*)updater;
@optional
// Refresh Interval
- (NSTimeInterval) refreshIntervalForUpdater:(DataUpdater*)updater;
// Date
- (NSDate*) dataDateForUpdater:(DataUpdater*)updater;
- (void) setUpdater:(DataUpdater*)updater dataDate:(NSDate*)date;
// SHA-1
- (NSString*) knownDataSha1ForUpdater:(DataUpdater*)updater;
- (void) setUpdater:(DataUpdater*)updater knownDataSha1:(NSString*)sha1;
@end
