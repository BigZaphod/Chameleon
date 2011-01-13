//  Created by Sean Heber on 6/1/10.
#import "UIEvent+UIPrivate.h"
#import "UITouch.h"

@implementation UIEvent
@synthesize timestamp=_timestamp, type=_type;

- (id)initWithEventType:(UIEventType)type
{
	if ((self=[super init])) {
		_type = type;
		_unhandledKeyPressEvent = NO;
	}
	return self;
}

- (void)dealloc
{
	[_touch release];
	[super dealloc];
}

- (void)_setTouch:(UITouch *)t
{
	if (_touch != t) {
		[_touch release];
		_touch = [t retain];
	}
}

- (void)_setTimestamp:(NSTimeInterval)timestamp
{
	_timestamp = timestamp;
}

// this is stupid hack so that keyboard events can fall to AppKit's next responder if nothing within UIKit handles it
// I couldn't come up with a better way at the time. meh.
- (void)_setUnhandledKeyPressEvent
{
	_unhandledKeyPressEvent = YES;
}

- (BOOL)_isUnhandledKeyPressEvent
{
	return _unhandledKeyPressEvent;
}

- (NSSet *)allTouches
{
	return [NSSet setWithObject:_touch];
}

- (NSSet *)touchesForView:(UIView *)view
{
	NSMutableSet *touches = [NSMutableSet setWithCapacity:1];
	for (UITouch *touch in [self allTouches]) {
		if (touch.view == view) {
			[touches addObject:touch];
		}
	}
	return touches;
}

- (NSSet *)touchesForWindow:(UIWindow *)window
{
	NSMutableSet *touches = [NSMutableSet setWithCapacity:1];
	for (UITouch *touch in [self allTouches]) {
		if (touch.window == window) {
			[touches addObject:touch];
		}
	}
	return touches;
}

- (UIEventSubtype)subtype
{
	return UIEventSubtypeNone;
}

@end
