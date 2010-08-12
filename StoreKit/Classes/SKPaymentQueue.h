//  Created by Sean Heber on 8/12/10.
#import <Foundation/Foundation.h>

@class SKPayment, SKPaymentTransaction;

@protocol SKPaymentTransactionObserver <NSObject>
@end

@interface SKPaymentQueue : NSObject {
}

+ (BOOL)canMakePayments;

+ (SKPaymentQueue *)defaultQueue;

- (void)addTransactionObserver:(id<SKPaymentTransactionObserver>)observer;
- (void)removeTransactionObserver:(id<SKPaymentTransactionObserver>)observer;

- (void)addPayment:(SKPayment *)payment;
- (void)finishTransaction:(SKPaymentTransaction *)transaction;

- (void)restoreCompletedTransactions;

@property(nonatomic, readonly) NSArray *transactions;

@end
