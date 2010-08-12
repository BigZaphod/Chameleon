//  Created by Sean Heber on 8/12/10.
#import "SKProductsRequest.h"

@implementation SKProductsRequest
@dynamic delegate;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
	if ((self=[super init])) {
	}
	return self;
}

- (void)start
{
}

- (void)cancel
{
}

@end
