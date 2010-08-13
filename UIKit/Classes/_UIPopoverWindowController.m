//
//  PopoverWindowController.m
//  Ostrich
//
//  Created by Craig Hockenberry on 7/26/10.
//  Copyright 2010 The Iconfactory. All rights reserved.
//

#import "_UIPopoverWindowController.h"
#import "_UIPopoverWindow.h"
#import "UIPopoverController.h"

@implementation _UIPopoverWindowController

- (id)initWithPopoverWindow:(_UIPopoverWindow *)popoverWindow controller:(UIPopoverController *)controller
{
	if ((self=[super initWithWindow:popoverWindow])) {
		popoverController = controller;
	}
	return self;
}

#pragma mark Actions

- (void)performClose:(id)sender
{
}

#pragma mark Overrides

/*

NOTE: These methods are only called when loading from a NIB file.

- (void)windowWillLoad
{
	DebugLog(@"%s called", __PRETTY_FUNCTION__);
}

- (void)windowDidLoad
{
	DebugLog(@"%s called", __PRETTY_FUNCTION__);
}
*/

#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
	if ([notification object] == [self window]) {
		if ([popoverController.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)]) {
			[popoverController.delegate popoverControllerDidDismissPopover:popoverController];
		}
	}
}

- (BOOL)windowShouldClose:(id)sender
{
	BOOL shouldClose = YES;
	
	if ([popoverController.delegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)]) {
		shouldClose = [popoverController.delegate popoverControllerShouldDismissPopover:popoverController];
	}

	if (shouldClose) {
		// grab any pending editing changes in the text fields
		[self.window makeFirstResponder:self.window];
		return YES;
	} else {
		return NO;
	}
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
//	[self.window orderFront:self];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
}

- (void)windowDidResignKey:(NSNotification *)notification
{
//	[self.window orderOut:self];
}

- (void)animationDidEnd:(NSAnimation *)animation
{
	[self.window performClose:self];
}

- (void)windowDidResignMain:(NSNotification *)notification
{
	if ([NSApp isActive]) {
#if 0
		// fade window out
		NSMutableDictionary *windowDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
		[windowDictionary setObject:self.window forKey:NSViewAnimationTargetKey];
		[windowDictionary setObject:NSViewAnimationFadeOutEffect forKey:NSViewAnimationEffectKey];
		
		NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:windowDictionary, nil]];
		[animation setDuration:0.2f];
		[animation setAnimationCurve:NSAnimationLinear];
		[animation setDelegate:self];
		[animation startAnimation];
		[animation release];
#else
		[self.window performClose:self];
#endif
	}
}

@end
