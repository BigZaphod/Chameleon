//  Created by Sean Heber on 5/27/10.
#import "UIEvent.h"

@interface UIResponder : NSObject

- (id)init;

- (UIResponder *)nextResponder;
- (BOOL)isFirstResponder;
- (BOOL)canBecomeFirstResponder;
- (BOOL)becomeFirstResponder;
- (BOOL)canResignFirstResponder;
- (BOOL)resignFirstResponder;

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event;

@property (readonly) NSUndoManager *undoManager;

@end

@interface UIResponder (OSXExtensions)
// This message is sent down the responder chain so that views behind other views can make use of the scroll wheel (such as UIScrollView).
- (void)scrollWheelMoved:(CGPoint)delta withEvent:(UIEvent *)event;

// NOTE: mouseMoved:withEvent: does not follow the responder chain because that seems unecessarily heavy for something that happens so often
// and probably is not super useful for the types of things you'd likely need mouse tracking for.
- (void)mouseMoved:(CGPoint)delta withEvent:(UIEvent *)event;

// Return an NSCursor if you want to modify it or nil to use the default arrow.
// NOTE: mouseCursorForEvent: does not follow the responder chain (see mouseMoved:withEvent: above for some reasoning).
- (id)mouseCursorForEvent:(UIEvent *)event;	// return an NSCursor if you want to modify it, return nil to use default
@end
