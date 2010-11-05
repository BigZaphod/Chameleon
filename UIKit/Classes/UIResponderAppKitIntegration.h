//  Created by Sean Heber on 10/12/10.
#import "UIResponder.h"

@interface UIResponder (AppKitIntegration)
// This message is sent up the responder chain so that views behind other views can make use of the scroll wheel (such as UIScrollView).
- (void)scrollWheelMoved:(CGPoint)delta withEvent:(UIEvent *)event;

// This is sent up the responder chain when the app gets a rightMouseDown-like event from OSX. There is no rightMouseDragged or rightMouseUp.
- (void)rightClick:(UITouch *)touch withEvent:(UIEvent *)event;

// This message is sent up (down?) the responder chain. You may get these often - especially when the mouse moves over a view that has a lot
// of smaller subviews in it as the messages will be sent each time the view under the cursor changes. These only happen during normal mouse
// movement - not when clicking, click-dragging, etc so it won't happen in all possible cases that might maybe make sense. Also, due to the
// bolted-on nature of this, I'm not entirely convinced it is delivered from the best spot - but in practice, it'll probably be okay.
// NOTE: You might get this message twice since the message is sent both to the view being left and the one being exited and they could
// ultimately share the same superview or controller or something.
// If the mouse came in from outside the hosting UIKitView, the enteredView is nil. If the mouse left the UIKitView, the exitedView is nil.
- (void)mouseExitedView:(UIView *)exited enteredView:(UIView *)entered withEvent:(UIEvent *)event;

// This passed along the responder chain like everything else.
- (void)mouseMoved:(CGPoint)delta withEvent:(UIEvent *)event;

// Return an NSCursor if you want to modify it or nil to use the default arrow. Follows responder chain.
- (id)mouseCursorForEvent:(UIEvent *)event;	// return an NSCursor if you want to modify it, return nil to use default
@end
