#import <Foundation/Foundation.h>

@interface UIProxyObject : NSObject <NSCoding>

@property (retain) NSString* proxiedObjectIdentifier;

- (id) initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;

@end
