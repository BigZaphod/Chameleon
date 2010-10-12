//  Created by Sean Heber on 10/12/10.
#import "UIResponderAppKitIntegration.h"

@implementation UIResponder (UIAppKitIntegration)

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
