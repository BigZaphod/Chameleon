//  Created by Sean Heber on 5/27/10.
#import "UIResponder.h"
#import "UIWindow+UIPrivate.h"

@implementation UIResponder

- (id)init
{
	return [super init];
}

- (void)dealloc
{
	[super dealloc];
}

- (UIWindow *)window
{
	return nil;
}

- (UIResponder *)nextResponder
{
	return nil;
}

- (BOOL)isFirstResponder
{
	return ([[self window] _firstResponder] == self);
}

- (BOOL)canBecomeFirstResponder
{
	return NO;
}

- (BOOL)becomeFirstResponder
{
	UIResponder *firstResponder = [[self window] _firstResponder];
	if ([self canBecomeFirstResponder] && (!firstResponder || ([firstResponder canResignFirstResponder] && [firstResponder resignFirstResponder]))) {
		[[self window] _setFirstResponder:self];
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
	[[self window] _setFirstResponder:nil];
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
	return nil;
}

@end

@implementation UIResponder (OSXExtensions)

- (void)scrollWheelMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
	[[self nextResponder] scrollWheelMoved:delta withEvent:event];
}

- (void)mouseMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
}

- (id)mouseCursorForEvent:(UIEvent *)event
{
	return nil;
}

@end
