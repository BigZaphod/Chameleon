#import "UISegment.h"

static NSString* const kUISegmentInfoKey = @"UISegmentInfo";
static NSString* const kUISegmentPositionKey = @"UISegmentPosition";

@implementation UISegment
@synthesize title = _title, position = _position;

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        if ([coder containsValueForKey:kUISegmentInfoKey]) {
            self.title = [coder decodeObjectForKey:kUISegmentInfoKey];
        }
        if ([coder containsValueForKey:kUISegmentPositionKey]) {
            self.position = [coder decodeIntegerForKey:kUISegmentPositionKey];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)dealloc
{
    [_title release];
    [super dealloc];
}
@end
