#import "UIImageNibPlaceholder.h"


static NSString* const kUIImageHeightKey = @"UIImageHeight";
static NSString* const kUIImageWidthKey = @"UIImageWidth";
static NSString* const kUIResourceNameKey = @"UIResourceName";


@implementation UIImageNibPlaceholder 
@synthesize resourceName = _resourceName;

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        _size = CGSizeMake([coder decodeFloatForKey:kUIImageWidthKey], [coder decodeFloatForKey:kUIImageHeightKey]);
        _resourceName = [[coder decodeObjectForKey:kUIResourceNameKey] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

- (CGSize) size
{
    return _size;
}
                                                                        
@end
