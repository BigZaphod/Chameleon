//  Created by Sean Heber on 6/19/10.
#import <Cocoa/Cocoa.h>

@class UIScreen, UIWindow;

@interface UIKitView : NSView {
	UIScreen *_screen;
	UIWindow *_mainWindow;
	NSTrackingArea *_trackingArea;
}

@property (nonatomic, retain, readonly) UIScreen *UIScreen;
@property (nonatomic, retain, readonly) UIWindow *UIWindow;		// created on-demand to be the size of the UIScreen.bounds, flexible width/height, and calls makeKeyAndVisible when it is first created

@end
