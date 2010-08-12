//  Created by Sean Heber on 8/12/10.
#import "SKPaymentQueue.h"

@implementation SKPaymentQueue

+ (BOOL)canMakePayments
{
	return NO;
}

+ (SKPaymentQueue *)defaultQueue
{
	return nil;
}

- (void)addTransactionObserver:(id<SKPaymentTransactionObserver>)observer
{
}

- (void)removeTransactionObserver:(id<SKPaymentTransactionObserver>)observer
{
}

- (void)addPayment:(SKPayment *)payment
{
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction
{
}

- (void)restoreCompletedTransactions
{
}

- (NSArray *)transactions
{
	return nil;
}

@end
