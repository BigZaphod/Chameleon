#import <Foundation/Foundation.h>

@interface UINibInflationHelper : NSObject <NSKeyedUnarchiverDelegate>

- (id) initWithOwner:(id)owner externalObjects:(NSDictionary*)externalObjects;

@end
