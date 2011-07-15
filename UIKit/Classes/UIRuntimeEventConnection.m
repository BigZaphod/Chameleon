#import "UIRuntimeEventConnection.h"


static NSString* const kUIDestinationKey = @"UIDestination";
static NSString* const kUILabelKey = @"UILabel";
static NSString* const kUISourceKey = @"UISource";
static NSString* const kUIEventMaskKey = @"UIEventMask";


@implementation UIRuntimeEventConnection
@synthesize control = _control;
@synthesize target = _target;
@synthesize action = _action;
@synthesize eventMask = _eventMask;

- (void) dealloc
{
    [_control release];
    [_target release];
    [super dealloc];
}

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        self.control = [coder decodeObjectForKey:kUISourceKey];
        self.target = [coder decodeObjectForKey:kUIDestinationKey];
        self.action = NSSelectorFromString([coder decodeObjectForKey:kUILabelKey]);
        self.eventMask = [coder decodeIntegerForKey:kUIEventMaskKey];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void) connect
{
    if ([_target respondsToSelector:_action]) {
        [_control addTarget:_target action:_action forControlEvents:_eventMask];
    } else {
        // Warn?
    }
}

@end
