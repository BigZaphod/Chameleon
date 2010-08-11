//  Created by Sean Heber on 8/11/10.
#import "UIApplication.h"

@class UIWindow, UIScreen, NSEvent;

@interface UIApplication (UIPrivate)
- (void)_setKeyWindow:(UIWindow *)newKeyWindow;
- (void)_windowDidBecomeVisible:(UIWindow *)theWindow;
- (void)_windowDidBecomeHidden:(UIWindow *)theWindow;
- (void)_screen:(UIScreen *)theScreen didReceiveNSEvent:(NSEvent *)theEvent;
@end
