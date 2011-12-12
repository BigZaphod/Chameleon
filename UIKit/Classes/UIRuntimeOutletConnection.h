#import <Foundation/Foundation.h>
#import "UIRuntimeEventConnection.h"

@interface UIRuntimeOutletConnection : NSObject <NSCoding> {
    id _target;
    id _value;
    NSString *_key;
}

@property (retain, nonatomic) id target;
@property (retain, nonatomic) id value;
@property (retain, nonatomic) NSString *key;

- (void) connect;

@end
