//  Created by Sean Heber on 6/1/10.
#import "UITouch+UIPrivate.h"
#import "UIWindow.h"
#import <Cocoa/Cocoa.h>

@implementation UITouch
@synthesize timestamp=_timestamp, tapCount=_tapCount, phase=_phase, view=_view, window=_window, gestureRecognizers=_gestureRecognizers;

- (id)init
{
	if ((self=[super init])) {
		_phase = UITouchPhaseCancelled;
	}
	return self;
}

- (void)dealloc
{
	[_window release];
	[_view release];
	[_gestureRecognizers release];
	[super dealloc];
}

- (void)_setPhase:(UITouchPhase)phase screenLocation:(CGPoint)screenLocation tapCount:(NSUInteger)tapCount delta:(CGPoint)delta timestamp:(NSTimeInterval)timestamp
{
	BOOL locationChanged = NO;
	
	if (!CGPointEqualToPoint(screenLocation, _location)) {
		_previousLocation = _location;
		_location = screenLocation;
		locationChanged = YES;
	}

	if (phase != _phase || locationChanged || tapCount != _tapCount || !CGPointEqualToPoint(_delta,delta)) {
		_timestamp = timestamp;
		_phase = phase;
		_tapCount = tapCount;
		_delta = delta;
	}
}

- (void)_setView:(UIView *)view
{
	if (_view != view) {
		[_view release];
		[_window release];
		_view = [view retain];
		_window = [view.window retain];
	}
}

- (void)_setTouchPhaseCancelled
{
	_phase = UITouchPhaseCancelled;
}

- (CGPoint)_delta
{
	return _delta;
}

- (UIWindow *)window
{
	return _window;
}

- (CGPoint)_convertLocationPoint:(CGPoint)thePoint toView:(UIView *)inView
{
	UIWindow *window = self.window;
	
	// The stored location should always be in the coordinate space of the UIScreen that contains the touch's window.
	// So first convert from the screen to the window:
	CGPoint point = [window convertPoint:thePoint fromWindow:nil];
	
	// Then convert to the desired location (if any).
	if (inView) {
		point = [inView convertPoint:point fromView:window];
	}
	
	return point;
}

- (CGPoint)locationInView:(UIView *)inView
{
	return [self _convertLocationPoint:_location toView:inView];
}

- (CGPoint)previousLocationInView:(UIView *)inView
{
	return [self _convertLocationPoint:_previousLocation toView:inView];
}

@end
