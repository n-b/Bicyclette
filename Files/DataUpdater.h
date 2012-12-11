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

- (id) initWithURL:(NSURL*)url delegate:(id<DataUpdaterDelegate>)delegate;
@property (readonly) NSURL* URL;
@property (nonatomic, weak) id<DataUpdaterDelegate> delegate;

- (void) cancel;

@end

/****************************************************************************/
#pragma mark -

@protocol DataUpdaterDelegate <NSObject>
- (void) updaterDidStartRequest:(DataUpdater*)updater;
- (void) updater:(DataUpdater*)updater didFailWithError:(NSError*)error;
- (void) updaterDidFinishWithNoNewData:(DataUpdater*)updater;
- (void) updater:(DataUpdater*)updater finishedWithNewData:(NSData*)data;

@optional
// SHA-1
- (NSString*) knownDataSha1ForUpdater:(DataUpdater*)updater;
- (void) setUpdater:(DataUpdater*)updater knownDataSha1:(NSString*)sha1;
@end
