//  Created by Sean Heber on 5/27/10.
#import "UIResponder.h"
#import "UIWindow+UIPrivate.h"

@implementation UIResponder

- (UIResponder *)nextResponder
{
	return nil;
}

- (UIWindow *)_responderWindow
{
	return [self isKindOfClass:[UIView class]]? [(UIView *)self window] : nil;
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
	if ([self isFirstResponder]) {
		return YES;
	} else {
		UIWindow *window = [self _responderWindow];
		UIResponder *firstResponder = [window _firstResponder];
		
		if (window && [self canBecomeFirstResponder]) {
			BOOL didResign = NO;
			
			if (firstResponder && [firstResponder canResignFirstResponder]) {
				didResign = [firstResponder resignFirstResponder];
			} else {
				didResign = YES;
			}
			
			if (didResign) {
				[window makeKeyWindow];		// not sure about this :/
				[window _setFirstResponder:self];
				return YES;
			}
		}

		return NO;
	}
}

- (BOOL)canResignFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	if ([self isFirstResponder]) {
		[[self _responderWindow] _setFirstResponder:nil];
	}
	
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
