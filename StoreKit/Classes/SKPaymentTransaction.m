//  Created by Sean Heber on 8/12/10.
#import "SKPaymentTransaction.h"

@implementation SKPaymentTransaction

- (NSError *)error
{
	return nil;
}

- (SKPayment *)payment
{
	return nil;
}

- (SKPaymentTransactionState)transactionState
{
	return SKPaymentTransactionStateFailed;
}

- (NSString *)transactionIdentifier
{
	return nil;
}

- (NSData *)transactionReceipt
{
	return nil;
}

- (NSDate *)transactionDate
{
	return nil;
}

- (SKPaymentTransaction *)originalTransaction
{
	return nil;
}

@end
