//  Created by Sean Heber on 5/27/10.
#import "UIResponder.h"
#import "UIKit+Private.h"

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
	return YES;
}

- (NSUndoManager *)undoManager
{
	return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event			{}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event			{}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event			{}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event		{}
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event		{}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event		{}
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event	{}

@end

@implementation UIResponder (OSXExtensions)

- (void)scrollWheelMoved:(NSValue *)delta withEvent:(UIEvent *)event		{}
- (void)mouseMoved:(NSValue *)delta withEvent:(UIEvent *)event				{}

- (id)mouseCursorForEvent:(UIEvent *)event
{
	return nil;
}

@end
