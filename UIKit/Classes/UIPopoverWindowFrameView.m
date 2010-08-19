//
//  PopoverWindowFrameView.m
//  Ostrich
//
//  Created by Craig Hockenberry on 7/26/10.
//  Copyright 2010 The Iconfactory. All rights reserved.
//

#import "UIPopoverWindowFrameView.h"

const CGFloat popoverWindowFrameTitleHeight = 21.0f;
const CGFloat popoverWindowFrameBorderWidth = 4.0f;
const CGFloat popoverWindowFrameEdgeWidth = 25.0f;

const CGFloat popoverWindowFrameArrowWidth = 40.0f;

static NSBezierPath *BezierPathForWindowTitle(NSRect aRect)
{
	NSBezierPath* path = [NSBezierPath bezierPath];
	
	float radius = 6.5;
	radius = MIN(radius, 0.5f * MIN(NSWidth(aRect), NSHeight(aRect)));
	NSRect rect = NSInsetRect(aRect, radius, radius);
	
	{
		NSPoint cornerPoint = NSMakePoint(NSMinX(aRect), NSMinY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
	
	{
		NSPoint cornerPoint = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
	
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect)) radius:radius startAngle:  0.0 endAngle: 90.0];
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect)) radius:radius startAngle: 90.0 endAngle:180.0];
	
	[path closePath];
	return path;	
}


@implementation UIPopoverWindowFrameView

@synthesize point;
@synthesize edge;

#if 0
// returns the bounds of the resize box
- (NSRect)resizeRect
{
	const CGFloat resizeBoxSize = 8.0;
	const CGFloat contentViewPadding = 0.0;

	NSWindow *window = self.window;
	
	NSRect contentViewRect = [window contentRectForFrameRect:window.frame];
	NSRect resizeRect = NSMakeRect(
			NSMaxX(contentViewRect) + contentViewPadding,
			NSMinY(contentViewRect) - resizeBoxSize - contentViewPadding,
			resizeBoxSize,
			resizeBoxSize);
	
	return resizeRect;
}

// handles mouse clicks in the frame
//	- click in the resize box changes window frame
//	- click anywhere else will drag the window
- (void)mouseDown:(NSEvent *)event
{
	NSPoint pointInView = [self convertPoint:[event locationInWindow] fromView:nil];
	
	BOOL resize = NO;
	if (NSPointInRect(pointInView, [self resizeRect])) {
		resize = YES;
	}
	
	NSWindow *window = self.window;
	NSPoint originalMouseLocation = [window convertBaseToScreen:[event locationInWindow]];
	NSRect originalFrame = window.frame;
	
    while (YES) {
		// lock focus and take all the dragged and mouse up events
        NSEvent *newEvent = [window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if ([newEvent type] == NSLeftMouseUp) {
			break;
		}
		
		// figure out how much the mouse has moved
		NSPoint newMouseLocation = [window convertBaseToScreen:[newEvent locationInWindow]];
		NSPoint delta = NSMakePoint(newMouseLocation.x - originalMouseLocation.x, newMouseLocation.y - originalMouseLocation.y);
		
		NSRect newFrame = originalFrame;
		
		if (! resize) {
			// drag the frame
			newFrame.origin.x += delta.x;
			newFrame.origin.y += delta.y;
		}
		else {
			// resize the frame
			newFrame.size.width += delta.x;
			newFrame.size.height -= delta.y;
			newFrame.origin.y += delta.y;
			
			// constrain the window size
			NSRect newContentRect = [window contentRectForFrameRect:newFrame];
			NSSize maxSize = [window maxSize];
			NSSize minSize = [window minSize];

			if (newContentRect.size.width > maxSize.width) {
				newFrame.size.width -= newContentRect.size.width - maxSize.width;
			}
			else if (newContentRect.size.width < minSize.width) {
				newFrame.size.width += minSize.width - newContentRect.size.width;
			}

			if (newContentRect.size.height > maxSize.height) {
				newFrame.size.height -= newContentRect.size.height - maxSize.height;
				newFrame.origin.y += newContentRect.size.height - maxSize.height;
			}
			else if (newContentRect.size.height < minSize.height) {
				newFrame.size.height += minSize.height - newContentRect.size.height;
				newFrame.origin.y -= minSize.height - newContentRect.size.height;
			}
		}
		
		[window setFrame:newFrame display:YES animate:NO];
	}
}
#endif

- (void)drawRect:(NSRect)rect
{
	BOOL isMainWindow = [self.window isMainWindow];
	
	[[NSColor clearColor] set];
	NSRectFill(rect);

#if 0
	[[NSColor whiteColor] set];
	NSFrameRect(rect);
#endif

	NSRect bounds = self.bounds;
	
	NSRect titleRect = NSZeroRect;
	NSRect borderRect = NSZeroRect;

	switch (edge) {
		case _UIPopoverWindowFrameEdgeLeft:
			borderRect.origin.x = bounds.origin.x;
			borderRect.origin.y = bounds.origin.y;
			borderRect.size.width = bounds.size.width - popoverWindowFrameEdgeWidth;
			borderRect.size.height = bounds.size.height - popoverWindowFrameTitleHeight;

			titleRect.origin.y = bounds.size.height - popoverWindowFrameTitleHeight;
			titleRect.size.width = bounds.size.width - popoverWindowFrameEdgeWidth;
			titleRect.size.height = popoverWindowFrameTitleHeight;
			break;
		case _UIPopoverWindowFrameEdgeRight:
			borderRect.origin.x = bounds.origin.x + popoverWindowFrameEdgeWidth;
			borderRect.origin.y = bounds.origin.y;
			borderRect.size.width = bounds.size.width - popoverWindowFrameEdgeWidth;
			borderRect.size.height = bounds.size.height - popoverWindowFrameTitleHeight;

			titleRect.origin.x = bounds.origin.x + popoverWindowFrameEdgeWidth;
			titleRect.origin.y = bounds.size.height - popoverWindowFrameTitleHeight;
			titleRect.size.width = bounds.size.width - popoverWindowFrameEdgeWidth;
			titleRect.size.height = popoverWindowFrameTitleHeight;
			break;
		case _UIPopoverWindowFrameEdgeBottom:
			borderRect.origin.x = bounds.origin.x;
			borderRect.origin.y = bounds.origin.y;
			borderRect.size.width = bounds.size.width;
			borderRect.size.height = bounds.size.height - popoverWindowFrameEdgeWidth - popoverWindowFrameTitleHeight;

			titleRect.origin.x = bounds.origin.x;
			titleRect.origin.y = bounds.size.height - popoverWindowFrameEdgeWidth - popoverWindowFrameTitleHeight;
			titleRect.size.width = bounds.size.width;
			titleRect.size.height = popoverWindowFrameTitleHeight;
			break;
		case _UIPopoverWindowFrameEdgeTop:
			borderRect.origin.x = bounds.origin.x;
			borderRect.origin.y = bounds.origin.y + popoverWindowFrameEdgeWidth;
			borderRect.size.width = bounds.size.width;
			borderRect.size.height = bounds.size.height - popoverWindowFrameEdgeWidth - popoverWindowFrameTitleHeight;

			titleRect.origin.x = bounds.origin.x;
			titleRect.origin.y = bounds.size.height - popoverWindowFrameTitleHeight;
			titleRect.size.width = bounds.size.width;
			titleRect.size.height = popoverWindowFrameTitleHeight;
			break;
	}

	NSBezierPath *titlePath = BezierPathForWindowTitle(titleRect);
	
	NSColor *startColor = nil;
	NSColor *endColor = nil;
	if (isMainWindow) {
		//startColor = [NSColor colorWithCalibratedRed:0.0f green:0.125f blue:0.25f alpha:0.8f];
		//endColor = [NSColor colorWithCalibratedRed:0.0f green:0.25f blue:0.5f alpha:0.8f];
		
		startColor = [NSColor colorWithCalibratedRed:43/255.f green:43/255.f blue:43/255.f alpha:0.9];
		endColor = [NSColor colorWithCalibratedRed:60/255.f green:60/255.f blue:60/255.f alpha:0.9];
	}
	else {
		startColor = [NSColor colorWithCalibratedRed:0.0f green:0.125f blue:0.25f alpha:1.0f];
		endColor = [NSColor colorWithCalibratedRed:0.0f green:0.25f blue:0.5f alpha:1.0f];
	}
	NSGradient* gradient = [[[NSGradient alloc] initWithColorsAndLocations: startColor, 0.0f, endColor, 1.0f, nil] autorelease];
	[gradient drawInBezierPath:titlePath angle:90];

	[startColor set];
	NSRectFill(borderRect);

	//[[NSColor whiteColor] set];
	//[framePath stroke];

	NSPoint arrowBaseStart = NSZeroPoint;
	NSPoint arrowBaseEnd = NSZeroPoint;

	switch (edge) {
		case _UIPopoverWindowFrameEdgeLeft:
			arrowBaseStart = NSMakePoint(borderRect.size.width, point.y + (popoverWindowFrameArrowWidth / 2.0f));
			arrowBaseEnd = NSMakePoint(borderRect.size.width, point.y - (popoverWindowFrameArrowWidth / 2.0f));
			break;
		case _UIPopoverWindowFrameEdgeRight:
			arrowBaseStart = NSMakePoint(borderRect.origin.x, point.y + (popoverWindowFrameArrowWidth / 2.0f));
			arrowBaseEnd = NSMakePoint(borderRect.origin.x, point.y - (popoverWindowFrameArrowWidth / 2.0f));
			break;
		case _UIPopoverWindowFrameEdgeBottom:
			arrowBaseStart = NSMakePoint(point.x + (popoverWindowFrameArrowWidth / 2.0f), borderRect.size.height + popoverWindowFrameTitleHeight);
			arrowBaseEnd = NSMakePoint(point.x - (popoverWindowFrameArrowWidth / 2.0f), borderRect.size.height + popoverWindowFrameTitleHeight);
			[endColor set];
			break;
		case _UIPopoverWindowFrameEdgeTop:
			arrowBaseStart = NSMakePoint(point.x + (popoverWindowFrameArrowWidth / 2.0f), borderRect.origin.y);
			arrowBaseEnd = NSMakePoint(point.x - (popoverWindowFrameArrowWidth / 2.0f), borderRect.origin.y);
			break;
	}
	
	//[[NSColor whiteColor] set];
	NSBezierPath *arrowPath = [NSBezierPath bezierPath];
	[arrowPath moveToPoint:arrowBaseStart];
	[arrowPath lineToPoint:point];
	[arrowPath lineToPoint:arrowBaseEnd];
	[arrowPath closePath];
	[arrowPath fill];

/*	
	NSRect resizeRect = [self resizeRect];
	NSBezierPath *resizePath = [NSBezierPath bezierPathWithRect:resizeRect];

	[[NSColor lightGrayColor] set];
	[resizePath fill];

	[[NSColor darkGrayColor] set];
	[resizePath stroke];
*/
	
	[[NSColor whiteColor] set];
	NSString *windowTitle = self.window.title;
	NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[paragraphStyle setAlignment:NSCenterTextAlignment];
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	shadow.shadowColor = [NSColor blackColor];
	shadow.shadowOffset = NSMakeSize(0.0f, 1.0f);
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
			paragraphStyle, NSParagraphStyleAttributeName,
			[NSFont systemFontOfSize:12], NSFontAttributeName,
			shadow, NSShadowAttributeName,
			[NSColor whiteColor], NSForegroundColorAttributeName,
			nil];
	NSRect drawRect = titleRect;
	drawRect.origin.y += 6.0f;
	drawRect.size.height -= 6.0f;
	[windowTitle drawWithRect:drawRect options:0 attributes:attributes];
}

@end
