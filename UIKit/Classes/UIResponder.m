//  Created by Sean Heber on 5/27/10.
#import "UIResponder.h"
#import "UIWindow+UIPrivate.h"

@implementation UIResponder

- (UIWindow *)_responderWindow
{
	if ([isa instancesRespondToSelector:@selector(window)]) {
		return [self performSelector:@selector(window)];
	} else {
		return [[self nextResponder] _responderWindow];
	}
}

- (UIResponder *)nextResponder
{
	return nil;
}

- (BOOL)isFirstResponder
{
	return ([[self _responderWindow] _firstResponder] == self);
}

- (BOOL)canBecomeFirstResponder
{
	return NO;
}

- (BOOL)becomeFirstResponder
{
	UIWindow *window = [self _responderWindow];
	UIResponder *firstResponder = [window _firstResponder];
	if (window && [self canBecomeFirstResponder] && (!firstResponder || ([firstResponder canResignFirstResponder] && [firstResponder resignFirstResponder]))) {
		[window makeKeyWindow];		// not sure about this :/
		[window _setFirstResponder:self];
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)canResignFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	[[self _responderWindow] _setFirstResponder:nil];
	return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
	if ([isa instancesRespondToSelector:action]) {
		return YES;
	} else {
		return [[self nextResponder] canPerformAction:action withSender:sender];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[self nextResponder] touchesCancelled:touches withEvent:event];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event		{}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event		{}
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event	{}

- (NSUndoManager *)undoManager
{
	return [[self nextResponder] undoManager];
}

@end

@implementation UIResponder (OSXExtensions)

- (void)scrollWheelMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
	[[self nextResponder] scrollWheelMoved:delta withEvent:event];
}

- (void)rightClick:(UITouch *)touch withEvent:(UIEvent *)event
{
	[[self nextResponder] rightClick:touch withEvent:event];
}

- (void)mouseEntered:(UIView *)view withEvent:(UIEvent *)event
{
	[[self nextResponder] mouseEntered:view withEvent:event];
}

- (void)mouseExited:(UIView *)view withEvent:(UIEvent *)event
{
	[[self nextResponder] mouseExited:view withEvent:event];
}

- (void)mouseMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
	[[self nextResponder] mouseMoved:delta withEvent:event];
}

- (id)mouseCursorForEvent:(UIEvent *)event
{
	return [[self nextResponder] mouseCursorForEvent:event];
}

@end
