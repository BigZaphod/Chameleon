#import "UIClassSwapper.h"


static NSString* const kUIClassNameKey = @"UIClassName";
static NSString* const kUIOriginalClassNameKey = @"UIOriginalClassName";


@implementation UIClassSwapper

- (id) initWithCoder:(NSCoder*)coder
{
    NSString* className = [coder decodeObjectForKey:kUIClassNameKey];
    Class class = NSClassFromString(className);
    if (!class) {
        NSString* originalClassName = [coder decodeObjectForKey:kUIClassNameKey];
        class = NSClassFromString(originalClassName);
    }
    [self release];
    return [[class alloc] initWithCoder:coder];
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
