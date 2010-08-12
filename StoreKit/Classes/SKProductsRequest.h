//  Created by Sean Heber on 8/12/10.
#import "SKRequest.h"

@protocol SKProductsRequestDelegate <SKRequestDelegate>
@end

@interface SKProductsRequest : SKRequest {
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)start;
- (void)cancel;

@property(nonatomic, assign) id<SKProductsRequestDelegate> delegate;

@end
