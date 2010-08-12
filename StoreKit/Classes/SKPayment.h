//  Created by Sean Heber on 8/12/10.
#import <Foundation/Foundation.h>

@interface SKPayment : NSObject {
}

+ (id)paymentWithProductIdentifier:(NSString *)identifier;

@property (nonatomic, readonly) NSString *productIdentifier;

@end
