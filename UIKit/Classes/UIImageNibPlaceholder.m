#import "UIImageNibPlaceholder.h"


static NSString* const kUIImageHeightKey = @"UIImageHeight";
static NSString* const kUIImageWidthKey = @"UIImageWidth";
static NSString* const kUIResourceNameKey = @"UIResourceName";


@implementation UIImageNibPlaceholder {
    NSString* _resourceName;
}

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        CGSize size = {
            .width = [coder decodeFloatForKey:kUIImageWidthKey],
            .height = [coder decodeFloatForKey:kUIImageHeightKey]
        };
        _resourceName = [[coder decodeObjectForKey:kUIResourceNameKey] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
