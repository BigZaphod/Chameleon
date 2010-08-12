//  Created by Sean Heber on 8/12/10.
#import <Foundation/Foundation.h>

@interface SKProductsResponse : NSObject {
}

@property (nonatomic, readonly) NSArray *products;
@property (nonatomic, readonly) NSArray *invalidProductIdentifiers;

@end
