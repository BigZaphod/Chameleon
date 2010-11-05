//  Created by Sean Heber on 6/1/10.
#import "UIEvent.h"
#import "UITouch.h"

@implementation UIEvent

- (id)init
{
	if ((self=[super init])) {
		_touch = [[UITouch alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[_touch release];
	[super dealloc];
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

- (UIEventType)type
{
	return UIEventTypeTouches;
}

- (UIEventSubtype)subtype
{
	return UIEventSubtypeNone;
}

- (NSTimeInterval)timestamp
{
	return [_touch timestamp];
}

@end
