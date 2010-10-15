//  Created by Sean Heber on 10/15/10.
#import <AppKit/NSView.h>

@class UIPopoverController;

@interface UIPopoverOverlayNSView : NSView {
	__weak UIPopoverController *_popoverController;
}

- (id)initWithFrame:(NSRect)frame popoverController:(UIPopoverController *)controller;

@end
