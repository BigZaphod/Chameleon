//  Created by Sean Heber on 6/19/10.
#import <Cocoa/Cocoa.h>
#import "UIApplicationDelegate.h"

@class UIScreen, UIWindow;

@interface UIKitView : NSView {
	UIScreen *_screen;
	UIWindow *_mainWindow;
	NSTrackingArea *_trackingArea;
}

// if UIApplication's keyWindow is on the screen represented by this UIKitView, this will send -canPerformAction:withSender: to the keyWindow's
// current first responder with the given action and sender and return the result. if the keyWindow is not on this screen, it always returns NO.
- (BOOL)firstResponderCanPerformAction:(SEL)action withSender:(id)sender;

// if UIApplication's keyWindow is on the screen represented by this UIKitView, this will send the action to the first responder of the keyWindow.
// otherwise it does nothing.
- (void)sendActionToFirstResponder:(SEL)action from:(id)sender;

// this is an optional method
// it will set the sharedApplication's delegate to appDelegate. if delay is >0, it will then look in the app bundle for
// various default.png images (ideally it would replicate the search pattern that the iPad does, but for now it's just
// uses Default-Landscape.png). If delay <= 0, it skips doing any launch stuff and just calls the delegate's
// applicationDidFinishLaunching: method. It's up to the app delegate to create its own window, just as it is in the real
// UIKit when not using a XIB.
// ** IMPORTANT: appDelegate is *not* retained! **
- (void)launchApplicationWithDelegate:(id<UIApplicationDelegate>)appDelegate afterDelay:(NSTimeInterval)delay;

// this is an optional property to make it quick and easy to get a window to start adding views to.
// created on-demand to be the size of the UIScreen.bounds, flexible width/height, and calls makeKeyAndVisible when it is first created
@property (nonatomic, retain, readonly) UIWindow *UIWindow;

// a UIKitView owns a single UIScreen. when the UIKitView is part of an NSWindow hierarchy, the UIScreen appears as a connected screen in
// [UIScreen screens], etc.
@property (nonatomic, retain, readonly) UIScreen *UIScreen;

@end
