//
//  PopoverWindow.m
//  Ostrich
//
//  Created by Craig Hockenberry on 7/26/10.
//  Copyright 2010 The Iconfactory. All rights reserved.
//

#import "_UIPopoverWindow.h"

#import "_UIPopoverWindowFrameView.h"

extern const CGFloat popoverWindowFrameTitleHeight;
extern const CGFloat popoverWindowFrameBorderWidth;
extern const CGFloat popoverWindowFrameEdgeWidth;

const CGFloat popoverWindowCloseButtonSize = 13.0f;

@implementation _UIPopoverWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:deferCreation];
	if (self) {
		[self setOpaque:NO];
		[self setBackgroundColor:[NSColor clearColor]];
		[self setHasShadow:YES];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidResignMainNotification object:self];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


// convert from childContentView to frameView for size
- (void)setContentSize:(NSSize)newSize
{
	NSSize sizeDelta = newSize;
	NSSize childBoundsSize = childContentView.bounds.size;
	sizeDelta.width -= childBoundsSize.width;
	sizeDelta.height -= childBoundsSize.height;
	
	_UIPopoverWindowFrameView *frameView = [super contentView];
	NSSize newFrameSize = frameView.bounds.size;
	newFrameSize.width += sizeDelta.width;
	newFrameSize.height += sizeDelta.height;
	
	[super setContentSize:newFrameSize];
}

// redraw the close button when the main window status changes
- (void)mainWindowChanged:(NSNotification *)aNotification
{
	[closeButton setNeedsDisplay];
	[super.contentView setNeedsDisplay:YES];
}

// keep the frame view as the content view and make the new view a child of that
- (void)setContentView:(NSView *)newView
{
	if ([childContentView isEqualTo:newView]) {
		return;
	}
	
	NSRect bounds = [self frame];
	bounds.origin = NSZeroPoint;

	_UIPopoverWindowFrameView *frameView = [super contentView];
	if (! frameView) {
		frameView = [[[_UIPopoverWindowFrameView alloc] initWithFrame:bounds] autorelease];
		
		[super setContentView:frameView];

#if 0
		closeButton = [NSWindow standardWindowButton:NSWindowCloseButton forStyleMask:NSBorderlessWindowMask];
		NSRect closeButtonRect = [closeButton frame];
		[closeButton setFrame:NSMakeRect(popoverWindowFramePadding - 10, bounds.size.height - (popoverWindowFramePadding - 10) - closeButtonRect.size.height, closeButtonRect.size.width, closeButtonRect.size.height)];
		[closeButton setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
#if 1
		DebugLog(@"%s closeButton target = %@, action = %@", __PRETTY_FUNCTION__, [closeButton target], NSStringFromSelector([closeButton action]));
		[closeButton setTarget:nil];
		[closeButton setAction:@selector(performClose:)];
		DebugLog(@"%s closeButton target = %@, action = %@", __PRETTY_FUNCTION__, [closeButton target], NSStringFromSelector([closeButton action]));
#endif
#else
		closeButton = [[NSButton alloc] initWithFrame:NSZeroRect];
		//[closeButton setFrame:NSMakeRect(3.0f, bounds.size.height - 3.0f - 13.0f, 13.0f, 13.0f)];
		[closeButton setButtonType:NSMomentaryChangeButton];
		[closeButton setBordered:NO];
		[closeButton setImage:[NSImage imageNamed:@"close.tif"]];
		[closeButton setImagePosition:NSImageOnly];
		[closeButton setFocusRingType:NSFocusRingTypeNone];
		[closeButton setTarget:nil];
		[closeButton setAction:@selector(performClose:)];
		//[closeButton setAutoresizingMask:NSViewMinYMargin];
		[closeButton setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
		[[closeButton cell] accessibilitySetOverrideValue:@"Close" forAttribute:NSAccessibilityDescriptionAttribute];
#endif

		[frameView addSubview:closeButton];
	}
	
	if (childContentView) {
		[childContentView removeFromSuperview];
	}
	childContentView = newView;
	[childContentView setFrame:[self contentRectForFrameRect:bounds]];
	[childContentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	[frameView addSubview:childContentView];
}

- (NSView *)contentView
{
	return childContentView;
}

// overrides the default to allow a borderless window to be the key window
- (BOOL)canBecomeKeyWindow
{
	return YES;
}

// overrides the default to allow a borderless window to be the main window
- (BOOL)canBecomeMainWindow
{
	return YES;
}

// returns the rect for the content rect, taking the frame
- (NSRect)contentRectForFrameRect:(NSRect)frameRect
{
	NSRect contentRect = NSZeroRect;
	
	contentRect.origin.x = frameRect.origin.x + popoverWindowFrameBorderWidth;
	contentRect.origin.y = frameRect.origin.y + popoverWindowFrameBorderWidth;
	contentRect.size.height = frameRect.size.height - popoverWindowFrameTitleHeight - popoverWindowFrameBorderWidth;
	contentRect.size.width = frameRect.size.width - popoverWindowFrameBorderWidth - popoverWindowFrameBorderWidth;

	_UIPopoverWindowFrameView *frameView = [super contentView];
	switch (frameView.edge) {
		case _UIPopoverWindowFrameEdgeLeft:
			contentRect.size.width -= popoverWindowFrameEdgeWidth;
			break;
		case _UIPopoverWindowFrameEdgeRight:
			contentRect.origin.x += popoverWindowFrameEdgeWidth;
			contentRect.size.width -= popoverWindowFrameEdgeWidth;
			break;
		case _UIPopoverWindowFrameEdgeBottom:
			contentRect.size.height -= popoverWindowFrameEdgeWidth;
			break;
		case _UIPopoverWindowFrameEdgeTop:
			contentRect.origin.y += popoverWindowFrameEdgeWidth;
			contentRect.size.height -= popoverWindowFrameEdgeWidth;
			break;
	}

	return contentRect;
}

+ (NSRect)rawFrameRectForContentRect:(NSRect)contentRect
{
	NSRect frameRect = NSZeroRect;
	
	frameRect.origin.x = contentRect.origin.x - popoverWindowFrameBorderWidth;
	frameRect.origin.y = contentRect.origin.y - popoverWindowFrameBorderWidth;
	frameRect.size.height = contentRect.size.height + popoverWindowFrameTitleHeight + popoverWindowFrameBorderWidth;
	frameRect.size.width = contentRect.size.width + popoverWindowFrameBorderWidth + popoverWindowFrameBorderWidth;
	
	return frameRect;
}	

- (NSRect)adjustFrameRect:(NSRect)oldFrameRect forEdge:(_UIPopoverWindowFrameEdge)edge
{
	NSRect newFrameRect = oldFrameRect;
	
	switch (edge) {
		case _UIPopoverWindowFrameEdgeLeft:
			newFrameRect.origin.x -= popoverWindowFrameEdgeWidth;
			newFrameRect.size.width += popoverWindowFrameEdgeWidth;
			break;
		case _UIPopoverWindowFrameEdgeRight:
			newFrameRect.size.width += popoverWindowFrameEdgeWidth;
			break;
		case _UIPopoverWindowFrameEdgeBottom:
			newFrameRect.origin.y -= popoverWindowFrameEdgeWidth;
			newFrameRect.size.height += popoverWindowFrameEdgeWidth;
			break;
		case _UIPopoverWindowFrameEdgeTop:
			newFrameRect.size.height += popoverWindowFrameEdgeWidth;
			break;
	}

	return newFrameRect;
}

// ensure that the window is made larger than the content
//+ (NSRect)frameRectForContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle
- (NSRect)frameRectForContentRect:(NSRect)contentRect
{
	NSRect frameRect = [_UIPopoverWindow rawFrameRectForContentRect:contentRect];
	
	_UIPopoverWindowFrameView *frameView = [super contentView];
	frameRect = [self adjustFrameRect:frameRect forEdge:frameView.edge];

	return frameRect;
}

#pragma mark Geometry

- (void)setFrameForContentSize:(NSSize)size atPoint:(NSPoint)point inWindow:(NSWindow *)window
{
	// both point and window frame are in screen coordinates
	//NSRect windowFrame = window.frame;
	NSRect windowContentFrame = [window.contentView frame];	
	NSRect windowFrame = windowContentFrame;
	windowFrame.origin = [window convertBaseToScreen:windowFrame.origin];

	// find the point's distances to the closest horizontal and vertical edge
	_UIPopoverWindowFrameEdge horizontalEdge;
	CGFloat horizontalEdgeDistance;
	if (point.x < NSMidX(windowFrame)) {
		horizontalEdge = _UIPopoverWindowFrameEdgeLeft;
		horizontalEdgeDistance = point.x - NSMinX(windowFrame);
	}
	else {
		horizontalEdge = _UIPopoverWindowFrameEdgeRight;
		horizontalEdgeDistance = NSMaxX(windowFrame) - point.x;
	}

	_UIPopoverWindowFrameEdge verticalEdge;
	CGFloat verticalEdgeDistance;
	if (point.y < NSMidY(windowFrame)) {
		verticalEdge = _UIPopoverWindowFrameEdgeBottom;
		verticalEdgeDistance = point.y - NSMinY(windowFrame);
	}
	else {
		verticalEdge = _UIPopoverWindowFrameEdgeTop;
		verticalEdgeDistance = NSMaxY(windowFrame) - point.y;
	}

	NSRect rawContentRect = NSZeroRect;
	rawContentRect.size = size;
	NSRect rawFrameRect = [_UIPopoverWindow rawFrameRectForContentRect:rawContentRect];

	NSRect offsetFrameRect = rawFrameRect;
	_UIPopoverWindowFrameEdge edge;
	
	// choose the shortest distance to the edge
	if (horizontalEdgeDistance <= verticalEdgeDistance) {
		edge = horizontalEdge;
		if (edge == _UIPopoverWindowFrameEdgeLeft) {
			offsetFrameRect.origin.x = point.x - rawFrameRect.size.width;
			offsetFrameRect.origin.y = point.y - NSMidY(rawFrameRect);
		}
		else {
			offsetFrameRect.origin.x = point.x;
			offsetFrameRect.origin.y = point.y - NSMidY(rawFrameRect);
		}
	}
	else {
		edge = verticalEdge;
		if (edge == _UIPopoverWindowFrameEdgeBottom) {
			offsetFrameRect.origin.x = point.x - NSMidX(rawFrameRect);
			offsetFrameRect.origin.y = point.y - rawFrameRect.size.height;
		}
		else {
			offsetFrameRect.origin.x = point.x - NSMidX(rawFrameRect);
			offsetFrameRect.origin.y = point.y;
		}
	}
	offsetFrameRect = [self adjustFrameRect:offsetFrameRect forEdge:edge];

	NSRect screenRect = window.screen.visibleFrame;
	
	NSRect adjustedFrameRect = offsetFrameRect;

	// adjust the frame if it's off screen
	switch (edge) {
		case _UIPopoverWindowFrameEdgeLeft:
			if (NSMinX(offsetFrameRect) < NSMinX(screenRect)) {
				// no room on left edge of window, move to right edge
				edge = _UIPopoverWindowFrameEdgeRight;
				adjustedFrameRect.origin.x = point.x;
			}
			break;
		case _UIPopoverWindowFrameEdgeRight:
			if (NSMaxX(offsetFrameRect) > NSMaxX(screenRect)) {
				// no room on right edge, move to left edge
				edge = _UIPopoverWindowFrameEdgeLeft;
				adjustedFrameRect.origin.x = point.x - adjustedFrameRect.size.width;
			}
			break;
		case _UIPopoverWindowFrameEdgeBottom:
			if (NSMinY(offsetFrameRect) < NSMinY(screenRect)) {
				// no room on bottom edge, move to top edge
				edge = _UIPopoverWindowFrameEdgeTop;
				adjustedFrameRect.origin.y = point.y;
			}
			break;
		case _UIPopoverWindowFrameEdgeTop:
			if (NSMaxY(offsetFrameRect) > NSMaxY(screenRect)) {
				// no room on top edge, move to bottom edge
				edge = _UIPopoverWindowFrameEdgeBottom;
				adjustedFrameRect.origin.y = point.y - adjustedFrameRect.size.height;
			}
			break;
	}
	switch (edge) {
		case _UIPopoverWindowFrameEdgeLeft:
		case _UIPopoverWindowFrameEdgeRight:
			// shift vertical edge up or down to fit on screen
			if (NSMinY(offsetFrameRect) < NSMinY(screenRect)) {
				CGFloat adjustY = NSMinY(screenRect) - NSMinY(offsetFrameRect);
				adjustedFrameRect.origin.y = offsetFrameRect.origin.y + adjustY;
			}
			else if (NSMaxY(offsetFrameRect) > NSMaxY(screenRect)) {
				CGFloat adjustY = NSMaxY(offsetFrameRect) - NSMaxY(screenRect);
				adjustedFrameRect.origin.y = offsetFrameRect.origin.y - adjustY;
			}
			break;
		case _UIPopoverWindowFrameEdgeBottom:
		case _UIPopoverWindowFrameEdgeTop:
			// shift horizontal edge to fit on screen
			if (NSMinX(offsetFrameRect) < NSMinX(screenRect)) {
				CGFloat adjustX = NSMinX(screenRect) - NSMinX(offsetFrameRect);
				adjustedFrameRect.origin.x = offsetFrameRect.origin.x + adjustX;
			}
			else if (NSMaxX(offsetFrameRect) > NSMaxX(screenRect)) {
				CGFloat adjustX = NSMaxX(offsetFrameRect) - NSMaxX(screenRect);
				adjustedFrameRect.origin.x = offsetFrameRect.origin.x - adjustX;
			}
			break;
	}

	[self setFrame:adjustedFrameRect display:YES];

	// update frame view so it can draw the arrow
	_UIPopoverWindowFrameView *frameView = [super contentView];
	frameView.point = [self convertScreenToBase:point];
	frameView.edge = edge;
	[frameView setNeedsDisplay:YES];

	NSRect bounds = self.frame;
	bounds.origin = NSZeroPoint;
	NSRect contentRect = [self contentRectForFrameRect:bounds];
	
	NSRect closeButtonFrame = NSMakeRect(
			contentRect.origin.x,
			contentRect.origin.y + contentRect.size.height + popoverWindowFrameTitleHeight - popoverWindowFrameBorderWidth - popoverWindowCloseButtonSize,			popoverWindowCloseButtonSize,
			popoverWindowCloseButtonSize);
	[closeButton setFrame:closeButtonFrame];

	[childContentView setFrame:contentRect];
}

#pragma mark Actions

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	BOOL result;
	
	// NOTE: NSWindow's implementation will return NO even when there's an implementation of -performClose: -- probably
	// because it's checking for a close button (and there isn't one for a borderless window.) We know better.
	
	if ([menuItem action] == @selector(performClose:)) {
		result = [self respondsToSelector:@selector(performClose:)];
	}
	else {
		result = [super validateMenuItem:menuItem];
	}

	return result;
}

- (void)performClose:(id)sender
{
	// NOTE: according to the documentation for NSWindow's -performClose: this should be the default implementation, but
	// without this code, the borderless window cannot be closed with Cmd-W. Oddly, clicking on the close button calls
	// the -windowShouldClose: delegate method (via the private -_close method) and the window closes correctly.
	
	BOOL performClose = YES;
	if ([self.delegate respondsToSelector:@selector(windowShouldClose:)]) {
		performClose = [self.delegate windowShouldClose:sender];
	}
	if (performClose) {
		[self close];
	}
}

@end
