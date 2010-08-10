//  Created by Sean Heber on 5/27/10.
#import "UIWindow.h"
#import "UIScreen.h"
#import "UIKit+Private.h"
#import "UIScreenMode.h"
#import "UIApplication.h"
#import <Cocoa/Cocoa.h>

const UIWindowLevel UIWindowLevelNormal = 0;
const UIWindowLevel UIWindowLevelAlert = 0;
const UIWindowLevel UIWindowLevelStatusBar = 0;

NSString *const UIWindowDidBecomeVisibleNotification = @"UIWindowDidBecomeVisibleNotification";
NSString *const UIWindowDidBecomeHiddenNotification = @"UIWindowDidBecomeHiddenNotification";
NSString *const UIWindowDidBecomeKeyNotification = @"UIWindowDidBecomeKeyNotification";
NSString *const UIWindowDidResignKeyNotification = @"UIWindowDidResignKeyNotification";
NSString *const UIKeyboardWillShowNotification = @"UIKeyboardWillShowNotification";
NSString *const UIKeyboardDidShowNotification = @"UIKeyboardDidShowNotification";
NSString *const UIKeyboardWillHideNotification = @"UIKeyboardWillHideNotification";
NSString *const UIKeyboardDidHideNotification = @"UIKeyboardDidHideNotification";
NSString *const UIKeyboardBoundsUserInfoKey = @"UIKeyboardBoundsUserInfoKey";

@implementation UIWindow
@synthesize screen=_screen;

- (id)initWithFrame:(CGRect)theFrame
{
	if ((self=[super initWithFrame:theFrame])) {
		[self _makeHidden];	// do this first because before the screen is set, it will prevent any visibility notifications from being sent.
		self.screen = [UIScreen mainScreen];
		self.opaque = NO;
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self _makeHidden];	// I don't really like this here, but the real UIKit seems to do something like this on window destruction as it sends a notification and we also need to remove it from the app's list of windows
	[_screen release];
	[super dealloc];
}

- (UIResponder *)_firstResponder
{
	return _firstResponder;
}

- (void)_setFirstResponder:(UIResponder *)newFirstResponder
{
	_firstResponder = newFirstResponder;
}

- (UIView *)superview
{
	return nil;		// lies!
}

- (void)removeFromSuperview
{
	// does nothing
}

- (UIWindow *)window
{
	return self;
}

- (UIResponder *)nextResponder
{
	return [UIApplication sharedApplication];
}

- (void)setScreen:(UIScreen *)theScreen
{
	if (theScreen != _screen) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenModeDidChangeNotification object:_screen];
		
		const BOOL wasHidden = self.hidden;
		[self _makeHidden];

		[self.layer removeFromSuperlayer];
		[_screen release];
		_screen = [theScreen retain];
		[[_screen _layer] addSublayer:self.layer];

		if (!wasHidden) {
			[self _makeVisible];
		}

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_screenModeChangedNotification:) name:UIScreenModeDidChangeNotification object:_screen];
	}
}

- (void)_screenModeChangedNotification:(NSNotification *)note
{
	UIScreenMode *previousMode = [[note userInfo] objectForKey:@"_previousMode"];
	UIScreenMode *newMode = _screen.currentMode;

	if (!CGSizeEqualToSize(previousMode.size,newMode.size)) {
		[self _superviewSizeDidChangeFrom:previousMode.size to:newMode.size];
	}
}

- (CGPoint)convertPoint:(CGPoint)toConvert toWindow:(UIWindow *)toWindow
{
	if (toWindow == self) {
		return toConvert;
	} else {
		// Convert to screen coordinates
		toConvert.x += self.frame.origin.x;
		toConvert.y += self.frame.origin.y;
		
		if (toWindow) {
			// Now convert the screen coords into the other screen's coordinate space
			toConvert = [self.screen convertPoint:toConvert toScreen:toWindow.screen];

			// And now convert it from the new screen's space into the window's space
			toConvert.x -= toWindow.frame.origin.x;
			toConvert.y -= toWindow.frame.origin.y;
		}
		
		return toConvert;
	}
}

- (CGPoint)convertPoint:(CGPoint)toConvert fromWindow:(UIWindow *)fromWindow
{
	if (fromWindow == self) {
		return toConvert;
	} else {
		if (fromWindow) {
			// Convert to screen coordinates
			toConvert.x += fromWindow.frame.origin.x;
			toConvert.y += fromWindow.frame.origin.y;
			
			// Change to this screen.
			toConvert = [self.screen convertPoint:toConvert fromScreen:fromWindow.screen];
		}
		
		// Convert to window coordinates
		toConvert.x -= self.frame.origin.x;
		toConvert.y -= self.frame.origin.y;

		return toConvert;
	}
}

- (CGRect)convertRect:(CGRect)toConvert fromWindow:(UIWindow *)fromWindow
{
	CGPoint convertedOrigin = [self convertPoint:toConvert.origin fromWindow:fromWindow];
	return CGRectMake(convertedOrigin.x, convertedOrigin.y, toConvert.size.width, toConvert.size.height);
}

- (CGRect)convertRect:(CGRect)toConvert toWindow:(UIWindow *)toWindow
{
	CGPoint convertedOrigin = [self convertPoint:toConvert.origin toWindow:toWindow];
	return CGRectMake(convertedOrigin.x, convertedOrigin.y, toConvert.size.width, toConvert.size.height);
}

- (void)becomeKeyWindow
{
	if ([[self _firstResponder] respondsToSelector:@selector(becomeKeyWindow)]) {
		[(id)[self _firstResponder] becomeKeyWindow];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeKeyNotification object:self];
}

- (void)makeKeyWindow
{
	if (!self.isKeyWindow) {
		[[UIApplication sharedApplication].keyWindow resignKeyWindow];
		[[UIApplication sharedApplication] _setKeyWindow:self];
		[self becomeKeyWindow];
	}
}

- (BOOL)isKeyWindow
{
	return ([UIApplication sharedApplication].keyWindow == self);
}

- (void)resignKeyWindow
{
	if ([[self _firstResponder] respondsToSelector:@selector(resignKeyWindow)]) {
		[(id)[self _firstResponder] resignKeyWindow];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidResignKeyNotification object:self];
}

- (void)_makeHidden
{
	if (!self.hidden) {
		[super setHidden:YES];
		if (self.screen) {
			[[UIApplication sharedApplication] _windowDidBecomeHidden:self];
			[[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeHiddenNotification object:self];
		}
	}
}

- (void)_makeVisible
{
	if (self.hidden) {
		[super setHidden:NO];
		if (self.screen) {
			[[UIApplication sharedApplication] _windowDidBecomeVisible:self];
			[[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeVisibleNotification object:self];
		}
	}
}

- (void)setHidden:(BOOL)hide
{
	if (hide) {
		[self _makeHidden];
	} else {
		[self _makeVisible];
	}
}

- (void)makeKeyAndVisible
{
	[self _makeVisible];
	[self makeKeyWindow];
}

- (void)setWindowLevel:(UIWindowLevel)level
{
	self.layer.zPosition = level;
}

- (UIWindowLevel)windowLevel
{
	return self.layer.zPosition;
}

- (void)sendEvent:(UIEvent *)event
{
	NSSet *allTouches = [event allTouches];
	UITouch *touch = (UITouch *)[allTouches anyObject];
	NSValue *delta = [NSValue valueWithCGPoint:CGPointMake([[event _NSEvent] deltaX],[[event _NSEvent] deltaY])];
	
	if (event.type == UIEventTypeTouches) {
		SEL action = NULL;
		
		switch (touch.phase) {
			case UITouchPhaseBegan:
				action = @selector(touchesBegan:withEvent:);
				break;
			case UITouchPhaseMoved:
				action = @selector(touchesMoved:withEvent:);
				break;
			case UITouchPhaseEnded:
				action = @selector(touchesEnded:withEvent:);
				break;
			case UITouchPhaseCancelled:
				action = @selector(touchesCancelled:withEvent:);
				break;
		}
		
		[[UIApplication sharedApplication] sendAction:action to:touch.view from:allTouches forEvent:event];
	} else if (event.type == _UIEventTypeMouseScroll) {
		[[UIApplication sharedApplication] sendAction:@selector(scrollWheelMoved:withEvent:) to:touch.view from:delta forEvent:event];
	} else if (event.type == _UIEventTypeMouseMoved) {
		// NOTE: mouseMoved:withEvent: does not follow the responder chain right now because that seems unecessarily heavy
		// and probably not super useful for the types of things you'd likely need mouse tracking for.
		[touch.view mouseMoved:delta withEvent:event];
	}

	// NOTE: mouseCursorForEvent: does not follow the responder chain for the same basic reasoning as for mouseMoved:withEvent:.
	NSCursor *newCursor = [touch.view mouseCursorForEvent:event] ?: [NSCursor arrowCursor];
	if ([NSCursor currentCursor] != newCursor) {
		[newCursor set];
	}
}

@end
