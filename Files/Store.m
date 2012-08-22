//
//  Store.m
//  Bicyclette
//
//  Created by Nicolas on 22/08/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "Store.h"

@interface Store () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property SKProductsRequest * productsRequest;
@end

@implementation Store

- (id)init
{
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

/****************************************************************************/
#pragma mark Request Products

- (BOOL) requestProducts
{
    if( ! [SKPaymentQueue canMakePayments])
        return NO;
    
    [self.productsRequest cancel];
    
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:@[@"ThankYou1", @"ThankYou4", @"ThankYou10"]]];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
    
    return YES;
}

/****************************************************************************/
#pragma mark Requests Delegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [self.delegate store:self productsRequestDidComplete:response.products];
}

- (void)requestDidFinish:(SKRequest *)request
{
    self.productsRequest = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    self.productsRequest = nil;
    [self.delegate store:self productsRequestDidFailWithError:error];
}

/****************************************************************************/
#pragma mark Payment

- (void) buy:(SKProduct*)product
{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction:(SKPaymentTransaction *)transaction
{
    [self.delegate store:self purchaseSucceeded:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    [self.delegate store:self purchaseSucceeded:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code == SKErrorPaymentCancelled) {
        [self.delegate store:self purchaseCancelled:transaction.payment.productIdentifier];
    }else {
        [self.delegate store:self purchaseFailed:transaction.payment.productIdentifier withError:transaction.error];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

@end
