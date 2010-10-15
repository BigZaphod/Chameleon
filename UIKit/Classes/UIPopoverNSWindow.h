//  Created by Sean Heber on 10/14/10.
#import <AppKit/NSWindow.h>

@class UIPopoverController;

@interface UIPopoverNSWindow : NSWindow {
	__weak UIPopoverController *_popoverController;
}

- (void)setPopoverController:(UIPopoverController *)controller;

@end
