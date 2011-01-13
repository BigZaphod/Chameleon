//  Created by Sean Heber on 8/11/10.
#import "UIApplication.h"

@class UIWindow, UIScreen, NSEvent, UIPopoverController;

@interface UIApplication (UIPrivate)
- (void)_setKeyWindow:(UIWindow *)newKeyWindow;
- (void)_windowDidBecomeVisible:(UIWindow *)theWindow;
- (void)_windowDidBecomeHidden:(UIWindow *)theWindow;
- (BOOL)_sendGlobalKeyboardNSEvent:(NSEvent *)theNSEvent fromScreen:(UIScreen *)theScreen;	// checks for CMD-Return/Enter and returns YES if it was handled, NO if not
- (BOOL)_sendKeyboardNSEvent:(NSEvent *)theNSEvent fromScreen:(UIScreen *)theScreen;		// returns YES if it was handled within UIKit (first calls _sendGlobalKeyboardNSEvent:fromScreen:)
- (void)_sendMouseNSEvent:(NSEvent *)theNSEvent fromScreen:(UIScreen *)theScreen;
- (void)_cancelTouchesInView:(UIView *)aView;
- (UIResponder *)_firstResponderForScreen:(UIScreen *)screen;
- (BOOL)_firstResponderCanPerformAction:(SEL)action withSender:(id)sender fromScreen:(UIScreen *)theScreen;
- (BOOL)_sendActionToFirstResponder:(SEL)action withSender:(id)sender fromScreen:(UIScreen *)theScreen;
@end
