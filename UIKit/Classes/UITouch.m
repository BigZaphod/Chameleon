//  Created by Sean Heber on 6/1/10.
#import "UITouch+UIPrivate.h"
#import "UIWindow.h"
#import <Cocoa/Cocoa.h>

@implementation UITouch
@synthesize timestamp=_timestamp, tapCount=_tapCount, phase=_phase, view=_view, window=_window;

- (void)_updateWithNSEvent:(NSEvent *)theEvent screenLocation:(CGPoint)screenLocation
{
	NSUInteger newTapCount = 0;
	UITouchPhase newPhase = UITouchPhaseStationary;
	BOOL locationChanged = NO;

	if (!CGPointEqualToPoint(screenLocation, _location)) {
		_previousLocation = _location;
		_location = screenLocation;
		locationChanged = YES;
	}
	
	switch ([theEvent type]) {
		case NSLeftMouseDown:
			newPhase = UITouchPhaseBegan;
			_previousLocation = screenLocation;
			locationChanged = YES;
			newTapCount = [theEvent clickCount];
			break;

		case NSLeftMouseDragged:
			newPhase = UITouchPhaseMoved;
			break;
			
		case NSLeftMouseUp:
			newPhase = UITouchPhaseEnded;
			newTapCount = [theEvent clickCount];
			break;
			
		default:
			newPhase = UITouchPhaseStationary;
			break;
	}
	
	if (newPhase != _phase || locationChanged || newTapCount != _tapCount) {
		_timestamp = [theEvent timestamp];
		_phase = newPhase;
		_tapCount = newTapCount;
	}
}

- (void)_setView:(UIView *)theView
{
	if (_view != theView) {
		[_view release];
		[_window release];
		
		_view = [theView retain];
		_window = [theView.window retain];
	}
}

- (CGPoint)_convertLocationPoint:(CGPoint)thePoint toView:(UIView *)inView
{
	// The stored location should always be in the coordinate space of the UIScreen that contains the touch's window.
	// So first convert from the screen to the window:
	CGPoint point = [self.window convertPoint:thePoint fromWindow:nil];
	
	// Then convert to the desired location (if any).
	if (inView) {
		point = [inView convertPoint:point fromView:self.window];
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

- (void)dealloc
{
	[_window release];
	[_view release];
	[super dealloc];
}

@end
