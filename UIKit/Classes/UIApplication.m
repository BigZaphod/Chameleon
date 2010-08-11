//  Created by Sean Heber on 5/28/10.
#import "UIApplication+UIPrivate.h"
#import "UIScreen+UIPrivate.h"
#import "UIEvent+UIPrivate.h"
#import "UITouch+UIPrivate.h"
#import "UIWindow.h"
#import <Cocoa/Cocoa.h>

NSString *const UIApplicationWillChangeStatusBarOrientationNotification = @"UIApplicationWillChangeStatusBarOrientationNotification";
NSString *const UIApplicationDidChangeStatusBarOrientationNotification = @"UIApplicationDidChangeStatusBarOrientationNotification";
NSString *const UIApplicationWillEnterForegroundNotification = @"UIApplicationWillEnterForegroundNotification";
NSString *const UIApplicationWillTerminateNotification = @"UIApplicationWillTerminateNotification";
NSString *const UIApplicationWillResignActiveNotification = @"UIApplicationWillResignActiveNotification";
NSString *const UIApplicationDidEnterBackgroundNotification = @"UIApplicationDidEnterBackgroundNotification";
NSString *const UIApplicationDidBecomeActiveNotification = @"UIApplicationDidBecomeActiveNotification";

NSString *const UITrackingRunLoopMode = @"UITrackingRunLoopMode";

static UIApplication *_theApplication = nil;

@implementation UIApplication
@synthesize keyWindow=_keyWindow, delegate=_delegate, idleTimerDisabled=_idleTimerDisabled;

+ (void)initialize
{
	if (self == [UIApplication class]) {
		_theApplication = [UIApplication new];
	}
}

+ (UIApplication *)sharedApplication
{
	return _theApplication;
}

- (id)init
{
	if ((self=[super init])) {
		_currentEvent = [UIEvent new];
		_visibleWindows = [NSMutableSet new];
	}
	return self;
}

- (void)dealloc
{
	[_currentEvent release];
	[_visibleWindows release];
	[super dealloc];
}

- (NSTimeInterval)statusBarOrientationAnimationDuration
{
	return 0.3;
}

- (BOOL)isStatusBarHidden
{
	return YES;
}

- (BOOL)isNetworkActivityIndicatorVisible
{
	return NO;  // lies!
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)b
{
	// nothing!
}

- (void)beginIgnoringInteractionEvents
{
}

- (void)endIgnoringInteractionEvents
{
}

- (UIInterfaceOrientation)statusBarOrientation
{
	return UIInterfaceOrientationPortrait;
}

- (void)setStatusBarOrientation:(UIInterfaceOrientation)orientation
{
}

- (void)_setKeyWindow:(UIWindow *)newKeyWindow
{
	_keyWindow = newKeyWindow;
}

- (void)_windowDidBecomeVisible:(UIWindow *)theWindow
{
	[_visibleWindows addObject:[NSValue valueWithNonretainedObject:theWindow]];
}

- (void)_windowDidBecomeHidden:(UIWindow *)theWindow
{
	if (theWindow == _keyWindow) [self _setKeyWindow:nil];
	[_visibleWindows removeObject:[NSValue valueWithNonretainedObject:theWindow]];
}

- (NSArray *)windows
{
	NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"windowLevel" ascending:YES] autorelease];
	return [[_visibleWindows valueForKey:@"nonretainedObjectValue"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}

- (BOOL)sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event
{
	if (!target) {
		// The docs say this method will start with the first responder if target==nil. Initially I thought this meant that there was always a given
		// or set first responder (attached to the window, probably). However it doesn't appear that is the case. Instead it seems UIKit is perfectly
		// happy to function without ever having any UIResponder having had a becomeFirstResponder sent to it. This method seems to work by starting
		// with sender and traveling down the responder chain from there if target==nil. The first object that responds to the given action is sent
		// the message. (or no one is)
		
		// My confusion comes from the fact that motion events and keyboard events are supposed to start with the first responder - but what is that
		// if none was ever set? Apparently the answer is, if none were set, the message doesn't get delivered. If you expicitly set a UIResponder
		// using becomeFirstResponder, then it will receive keyboard/motion events but it does not receive any other messages from other views that
		// happen to end up calling this method with a nil target. So that's a seperate mechanism and I think it's confused a bit in the docs.
		
		// It seems that the reality of message delivery to "first responder" is that it depends a bit on the source. If the source is an external
		// event like motion or keyboard, then there has to have been an explicitly set first responder (by way of becomeFirstResponder) in order for
		// those events to even get delivered at all. If there is no responder defined, the action is simply never sent and thus never received.
		// This is entirely independent of what "first responder" means in the context of a UIControl. Instead, for a UIControl, the first responder
		// is the first UIResponder (including the UIControl itself) that responds to the action. It starts with the UIControl (sender) and not with
		// whatever UIResponder may have been set with becomeFirstResponder.
		
		id responder = sender;
		while (responder) {
			if ([responder respondsToSelector:action]) {
				target = responder;
				break;
			} else if ([responder respondsToSelector:@selector(nextResponder)]) {
				responder = [responder nextResponder];
			} else {
				responder = nil;
			}
		}
	}
	
	if (target) {
		[target performSelector:action withObject:sender withObject:event];
		return YES;
	} else {
		return NO;
	}
}

- (void)sendEvent:(UIEvent *)event
{
	for (UITouch *touch in [event allTouches]) {
		[touch.window sendEvent:event];
	}
}

- (BOOL)openURL:(NSURL *)url
{
	return [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)_beginNewTouchForEvent:(UIEvent *)theEvent atScreen:(UIScreen *)theScreen location:(CGPoint)clickPoint
{
	UIView *clickedView = nil;
	UITouch *newTouch = [UITouch new];
	
	[newTouch _updateWithNSEvent:[theEvent _NSEvent] screenLocation:clickPoint];
	[theEvent _setTouch:newTouch];
	
	for (UIWindow *window in [self.windows reverseObjectEnumerator]) {
		if (window.screen == theScreen) {
			CGPoint windowPoint = [window convertPoint:clickPoint fromWindow:nil];
			clickedView = [window hitTest:windowPoint withEvent:theEvent];
			if (clickedView) {
				[newTouch _setView:clickedView];
				break;
			}
		}
	}
	
	[newTouch release];
}

- (void)_screen:(UIScreen *)theScreen didReceiveNSEvent:(NSEvent *)theNSEvent
{
	// All "touch" events are left mouse clicks (right now). A single touch "gesture" starts with the clicking of the left
	// mouse button, so the first thing to do is make sure that the click happened on a visible UIWindow. If it did, then
	// we have to capture which specific window and view it happened on. If ultimately there's no userInteractionEnabled=YES
	// views beneath the click, then we will simply ignore it.
	
	[_currentEvent _setNSEvent:theNSEvent];

	CGPoint clickPoint = NSPointToCGPoint([[theScreen _NSView] convertPoint:[theNSEvent locationInWindow] fromView:nil]);

	// the y coord from the NSView might be inverted
	if (![[theScreen _NSView] isFlipped]) {
		clickPoint.y = theScreen.bounds.size.height - clickPoint.y - 1;
	}
	
	switch ([theNSEvent type]) {
		case NSLeftMouseDown:
			[self _beginNewTouchForEvent:_currentEvent atScreen:theScreen location:clickPoint];
			[self sendEvent:_currentEvent];
			break;

		case NSLeftMouseDragged:
			[[_currentEvent _touch] _updateWithNSEvent:theNSEvent screenLocation:clickPoint];
			[self sendEvent:_currentEvent];
			break;
			
		case NSLeftMouseUp:
			[[_currentEvent _touch] _updateWithNSEvent:theNSEvent screenLocation:clickPoint];
			[self sendEvent:_currentEvent];
			[_currentEvent _setTouch:nil];
			break;

		case NSScrollWheel:
		case NSMouseMoved:
			if (![_currentEvent _touch]) {
				[self _beginNewTouchForEvent:_currentEvent atScreen:theScreen location:clickPoint];
				[self sendEvent:_currentEvent];
				[_currentEvent _setTouch:nil];
			}
			break;

		default:
			if ([_currentEvent _touch]) {
				[[_currentEvent _touch] _updateWithNSEvent:theNSEvent screenLocation:clickPoint];
				[self sendEvent:_currentEvent];
			}
			break;
	}
}

@end
