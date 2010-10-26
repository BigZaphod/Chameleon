//  Created by Sean Heber on 6/1/10.
#import "UIEvent+UIPrivate.h"
#import <Cocoa/Cocoa.h>

@implementation UIEvent

- (UIView *)_previousMouseMovementView
{
	return _previousMouseMovementView;
}

- (void)_setPreviousMouseMovementView:(UIView *)view
{
	if (view != _previousMouseMovementView) {
		[_previousMouseMovementView release];
		_previousMouseMovementView = [view retain];
	}
}

- (UITouch *)_touch
{
	return _touch;
}

- (void)_setTouch:(UITouch *)theTouch
{
	if (theTouch != _touch) {
		[_touch release];
		_touch = [theTouch retain];
	}
}

- (NSEvent *)_NSEvent
{
	return _event;
}

- (void)_setNSEvent:(NSEvent *)theEvent
{
	if (theEvent != _event) {
		[_event release];
		_event = [theEvent retain];
	}
}

- (UIEvent *)_cloneAndClearTouch
{
	UIEvent *event = [[UIEvent alloc] init];
	[event _setTouch:_touch];
	[event _setNSEvent:_event];
	[event _setPreviousMouseMovementView:_previousMouseMovementView];
	[self _setTouch:nil];
	return [event autorelease];
}

- (void)dealloc
{
	[_event release];
	[_touch release];
	[_previousMouseMovementView release];
	[super dealloc];
}

- (NSSet *)allTouches
{
	return [NSSet setWithObject:_touch];
}

- (NSSet *)touchesForView:(UIView *)view
{
	return nil;
}

- (NSSet *)touchesForWindow:(UIWindow *)window
{
	return nil;
}

- (UIEventType)type
{
	switch ([_event type]) {
		case NSScrollWheel:
			return _UIEventTypeMouseScroll;

		case NSMouseMoved:
			return _UIEventTypeMouseMoved;
			
		case NSRightMouseDown:
			return _UIEventTypeMouseRightClick;
			
		default:
			return UIEventTypeTouches;
	}
}

- (UIEventSubtype)subtype
{
	return UIEventSubtypeNone;
}

- (NSTimeInterval)timestamp
{
	return [_event timestamp];
}

@end
