//  Created by Sean Heber on 8/12/10.
#import <Foundation/Foundation.h>

@interface SKProduct : NSObject {
}

@property (nonatomic, readonly) NSString *productIdentifier;
@property (nonatomic, readonly) NSString *localizedTitle;
@property (nonatomic, readonly) NSString *localizedDescription;
@property (nonatomic, readonly) NSDecimalNumber *price;
@property (nonatomic, readonly) NSLocale *priceLocale;

@end
