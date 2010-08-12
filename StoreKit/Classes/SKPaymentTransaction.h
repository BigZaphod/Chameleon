//  Created by Sean Heber on 8/12/10.
#import <Foundation/Foundation.h>

@class SKPayment, SKPaymentTransaction;

enum {
	SKPaymentTransactionStatePurchasing,
	SKPaymentTransactionStatePurchased,
	SKPaymentTransactionStateFailed,
	SKPaymentTransactionStateRestored
};
typedef NSInteger SKPaymentTransactionState;

@interface SKPaymentTransaction : NSObject {
}

@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) SKPayment *payment;
@property (nonatomic, readonly) SKPaymentTransactionState transactionState;
@property (nonatomic, readonly) NSString *transactionIdentifier;
@property (nonatomic, readonly) NSData *transactionReceipt;
@property (nonatomic, readonly) NSDate *transactionDate;
@property (nonatomic, readonly) SKPaymentTransaction *originalTransaction;

@end
