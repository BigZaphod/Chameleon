//  Created by Sean Heber on 10/12/10.
#import "UIResponderAppKitIntegration.h"
#import "UIEvent+UIPrivate.h"

@implementation UIResponder (AppKitIntegration)

- (void)scrollWheelMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
	[[self nextResponder] scrollWheelMoved:delta withEvent:event];
}

- (void)rightClick:(UITouch *)touch withEvent:(UIEvent *)event
{
	[[self nextResponder] rightClick:touch withEvent:event];
}

- (void)mouseExitedView:(UIView *)exited enteredView:(UIView *)entered withEvent:(UIEvent *)event
{
	[[self nextResponder] mouseExitedView:exited enteredView:entered withEvent:event];
}

- (void)mouseMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
	[[self nextResponder] mouseMoved:delta withEvent:event];
}

- (id)mouseCursorForEvent:(UIEvent *)event
{
	return [[self nextResponder] mouseCursorForEvent:event];
}

- (void)keyPressed:(UIKey *)key withEvent:(UIEvent *)event
{
	UIResponder *responder = [self nextResponder];
	if (responder) {
		[responder keyPressed:key withEvent:event];
	} else {
		[event _setUnhandledKeyPressEvent];
	}
}

@end
