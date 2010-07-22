//  Created by Sean Heber on 6/19/10.
#import <Cocoa/Cocoa.h>

@class UIScreen;

@interface UIKitView : NSView {
	UIScreen *_screen;
	id _trackingArea;
}

@property (nonatomic, retain, readonly) UIScreen *screen;

@end
