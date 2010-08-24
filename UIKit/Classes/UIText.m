//  Created by Sean Heber on 8/23/10.
#import "UIText.h"
#import "UIClipNSView.h"
#import "UIView.h"
#import "UIFont+UIPrivate.h"
#import "UIColor+UIPrivate.h"
#import "UIWindow.h"
#import "UIScreen+UIPrivate.h"
#import <AppKit/NSTextStorage.h>
#import <AppKit/NSTextContainer.h>
#import <AppKit/NSLayoutManager.h>
#import <AppKit/NSTextView.h>
#import <AppKit/NSCursor.h>
#import <AppKit/NSColor.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CATextLayer.h>
#import <QuartzCore/CATransaction.h>



@interface FlippedLayer : CATextLayer
@end

@implementation FlippedLayer
- (void)setFrame:(CGRect)frame
{
	NSLog( @"setFrame: %@", NSStringFromCGRect(frame) );
	if ([self superlayer]) {
		frame.origin.y = [[self superlayer] bounds].size.height - frame.origin.y - frame.size.height;
	}
	[super setFrame:frame];
}
@end









@implementation UIText
@synthesize textColor, font;

- (void)setNeedsAttributeUpdate
{
	needsAttributeUpdate = YES;
	[containerView setNeedsDisplay];
}

- (NSRect)NSViewFrame
{
	const CGRect windowRect = [containerView.window convertRect:containerView.frame fromView:containerView.superview];
	const CGRect screenRect = [containerView.window convertRect:windowRect toWindow:nil];
	return NSRectFromCGRect(screenRect);
}

- (id)initWithContainerView:(UIView *)view
{
	if ((self=[super init])) {
		containerView = view;
		
		textStorage = [NSTextStorage new];
		layoutManager = [NSLayoutManager new];
		textContainer = [[NSTextContainer alloc] initWithContainerSize:NSSizeFromCGSize(containerView.bounds.size)];

		[textContainer setHeightTracksTextView:YES];
		[textContainer setWidthTracksTextView:YES];
		[textStorage addLayoutManager:layoutManager];
		[layoutManager addTextContainer:textContainer];
		[self setNeedsAttributeUpdate];

		/*
		clipView = [[UIClipNSView alloc] initWithFrame:[self NSViewFrame]];
		[clipView setContainerView:containerView];

		
		CALayer *fakeLayer = [CALayer layer];
		[clipView setLayer:fakeLayer];
		[clipView setWantsLayer:YES];
		[clipView setDrawsBackground:NO];
		[[clipView layer] setGeometryFlipped:YES];
		[clipView setAutoresizingMask:NSViewMinYMargin|NSViewMaxXMargin];
		
		textView = [[NSTextView alloc] initWithFrame:[clipView bounds]];
		[textView setDrawsBackground:NO];
		[textView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
		[clipView setDocumentView:textView];
		 */
	}
	return self;
}

- (BOOL)editable
{
	return NO;
	//return [textView isEditable];
}

- (void)setEditable:(BOOL)editable
{
	//[textView setEditable:editable];
}

- (void)setHidden:(BOOL)hidden
{
	/*
	if (hidden != self.hidden) {
		[clipView setHidden:hidden];
		[self updateFrame];
	}
	 */
}

- (void)setFont:(UIFont *)newFont
{
	NSAssert((newFont != nil), nil);
	if (newFont != font) {
		[font release];
		font = [newFont retain];
		//[textView setFont:[font _NSFont]];
		[self setNeedsAttributeUpdate];
	}
}

- (void)setTextColor:(UIColor *)newColor
{
	if (newColor != textColor) {
		[textColor release];
		textColor = [newColor retain];
		//[textView setTextColor:[textColor _NSColor]];
		[self setNeedsAttributeUpdate];
	}
}

- (NSString *)text
{
	//return [textView string];
	return [[[textStorage mutableString] copy] autorelease];
}

- (void)setText:(NSString *)newText
{
	//[textView setString:newText];
	[textStorage setAttributedString:[[[NSAttributedString alloc] initWithString:newText] autorelease]];
	[self setNeedsAttributeUpdate];
}

- (void)updateFrame
{
	/*
	[CATransaction begin];
	[CATransaction setAnimationDuration:0];

	if (isFirstResponder && containerView.window) {

		if (clipView) {
			[clipView setFrame:[self NSViewFrame]];
			[[containerView.window.screen _NSView] addSubview:clipView];
		} else {
			[textContainer setContainerSize:NSSizeFromCGSize(containerView.bounds.size)];
		}
		[containerView setNeedsDisplay];

		//[clipView setFrame:[self NSViewFrame]];
		//[[containerView.window.screen _NSView] addSubview:clipView];

	} else {
		[textContainer setTextView:nil];
		[textView release];
		textView = nil;
		[clipView removeFromSuperview];
		[clipView release];
		clipView = nil;
		//[clipView setFrameSize:NSSizeFromCGSize(containerView.bounds.size)];
	}

	[CATransaction commit];
	 */

	
	if (containerView.window) {
		[textContainer setContainerSize:NSSizeFromCGSize(containerView.bounds.size)];
		[containerView setNeedsDisplay];
	} else {
	}
}
 
/*
- (void)removeHierarchyObservers
{
	UIView *view = containerView.superview;
	while (view) {
		[view removeObserver:self forKeyPath:@"superview"];
		[view removeObserver:self forKeyPath:@"frame"];
		view = view.superview;
	}
}

- (void)buildHierarchyObserversForSuperview:(UIView *)view
{
	while (view) {
		[view addObserver:self forKeyPath:@"superview" options:NSKeyValueObservingOptionPrior context:NULL];
		[view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
		view = view.superview;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"superview"]) {
		if ([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue]) {
			[self removeHierarchyObservers];
		} else {
			[self buildHierarchyObserversForSuperview:containerView.superview];
		}
		[self updateFrame];
	} else if ([keyPath isEqualToString:@"frame"]) {
		CGRect oldFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
		CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
		if (!CGPointEqualToPoint(oldFrame.origin,newFrame.origin)) {
			[self updateFrame];
		}
	}
}
 */

- (void)containerViewWillMoveToSuperview:(UIView *)view
{
	//[self removeHierarchyObservers];
	//[self buildHierarchyObserversForSuperview:view];
}

- (void)containerViewDidMoveToSuperview
{
	[self updateFrame];
}

- (id)mouseCursorForEvent:(UIEvent *)event
{
	return [NSCursor IBeamCursor];
}

- (void)drawInRect:(CGRect)rect
{
	/*
	if (!isFirstResponder) {
		NSRange range = [[textView layoutManager] glyphRangeForBoundingRect:NSRectFromCGRect(rect) inTextContainer:[textView textContainer]];
		[[textView layoutManager] drawGlyphsForGlyphRange:range atPoint:NSPointFromCGPoint(rect.origin)];
	}
	 */
	
	if (needsAttributeUpdate) {
		needsAttributeUpdate = NO;
		NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
									[font _NSFont],			NSFontAttributeName,
									[textColor _NSColor],	NSForegroundColorAttributeName,
									nil];
		[textStorage setAttributes:attributes range:NSMakeRange(0,[textStorage length])];
		[attributes release];
	}

	NSRange range = [layoutManager glyphRangeForBoundingRect:NSRectFromCGRect(rect) inTextContainer:textContainer];
	[layoutManager drawGlyphsForGlyphRange:range atPoint:NSPointFromCGPoint(rect.origin)];
}


- (void)containerViewBecameFirstResponder
{
	/*
	NSTextView *textView = [[NSTextView alloc] initWithFrame:[self NSViewFrame] textContainer:textContainer];
	[textView setDrawsBackground:YES];
	[textView setBackgroundColor:[NSColor yellowColor]];
	[[containerView.window.screen _NSView] addSubview:textView];
	*/

	//isFirstResponder = YES;
	//[self updateFrame];
	
	/*
	if (!textView) {
		clipView = [[UIClipNSView alloc] initWithFrame:[self NSViewFrame]];
		[clipView setContainerView:containerView];

		[clipView setWantsLayer:YES];
		[clipView setDrawsBackground:YES];
		[clipView setBackgroundColor:[NSColor yellowColor]];
		[[clipView layer] setGeometryFlipped:YES];
		[(UIClipNSView *)clipView setAutoresizingMask:NSViewMinYMargin|NSViewMaxXMargin];
		
		textView = [[NSTextView alloc] initWithFrame:[clipView bounds] textContainer:textContainer];
		[textView setVerticallyResizable:YES];
		[textView setDrawsBackground:NO];
		//[(NSTextView *)textView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
		[clipView setDocumentView:textView];
	} else {
		[textContainer setTextView:textView];
	}
	
	[self updateFrame];
	 */
}

- (void)containerViewResignedFirstResponder
{
	//isFirstResponder = NO;
	//[self updateFrame];
	
	/*
	[textContainer setTextView:nil];
	[textView release];
	textView = nil;
	[clipView removeFromSuperview];
	[clipView release];
	clipView = nil;
	
	[self updateFrame];	// not sure?
	 */
}

- (void)dealloc
{
	//[self removeHierarchyObservers];
	
	//[clipView removeFromSuperview];
	//[textView release];
	//[clipView release];

	[textContainer release];
	[layoutManager release];
	[textStorage release];
	
	[textColor release];
	[font release];
	[super dealloc];
}

@end
