//
//  Store.h
//  Bicyclette
//
//  Created by Nicolas on 22/08/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

/****************************************************************************/
#pragma mark In-App Purchases

@protocol StoreDelegate;

@interface Store : NSObject

@property id<StoreDelegate> delegate;
- (BOOL) requestProducts:(NSArray*)productIdentifiers;
- (void) buy:(SKProduct*)product;
- (void) restore;
@end


/****************************************************************************/
#pragma mark Delegate

@protocol StoreDelegate <NSObject>
- (void) store:(Store*)store productsRequestDidComplete:(NSArray*)products;
- (void) store:(Store*)store productsRequestDidFailWithError:(NSError*)error;
- (void) store:(Store*)store purchaseSucceeded:(NSString*)productIdentifier;
- (void) store:(Store*)store purchaseCancelled:(NSString*)productIdentifier;
- (void) store:(Store*)store purchaseFailed:(NSString*)productIdentifier withError:(NSError*)error;
- (void) storeRestoreFinished:(Store*)store;
@end
