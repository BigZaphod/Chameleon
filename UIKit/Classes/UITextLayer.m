//  Created by Sean Heber on 8/26/10.
#import "UITextLayer.h"
#import "UIScrollView.h"
#import "UICustomNSTextView.h"
#import "UICustomNSClipView.h"
#import "UIWindow.h"
#import "UIScreen+UIPrivate.h"
#import "UIColor+UIPrivate.h"
#import "UIFont+UIPrivate.h"
#import <AppKit/NSLayoutManager.h>
#import <AppKit/NSTextStorage.h>

@interface UITextLayer ()
- (void)destroyNSViewsIfNeeded;
@end

@implementation UITextLayer
@synthesize textColor, font, editable, secureTextEntry;

- (id)initWithContainerView:(id)aView
{
	if ((self=[super init])) {
		self.geometryFlipped = YES;
		self.masksToBounds = NO;
		containerView = aView;
		textStorage = [NSTextStorage new];
		[self setNeedsLayout];
	}
	return self;
}

- (void)dealloc
{
	[self destroyNSViewsIfNeeded];
	[textStorage release];
	[textColor release];
	[font release];
	[super dealloc];
}



// These hierarchy observers are here because we have to keep the NSView's frame in sync with the UIViews, and they could potentially
// move out from under us. That would be bad. So these methods setup a chain of observers so that the layer can track where it REALLY
// is in the world and update the NSView's frame accordingly. All it has to so is set the layer (self) as needing layout because the
// actually process of syncing/creating/destroying the NSViews is all triggered from there.

- (void)removeHierarchyObservers
{
	UIView *view = containerView;
	while (view) {
		[view removeObserver:self forKeyPath:@"superview"];
		[view removeObserver:self forKeyPath:@"frame"];
		view = view.superview;
	}
}

- (void)buildHierarchyObservers
{
	UIView *view = containerView;
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
			[self buildHierarchyObservers];
		}
		[self setNeedsLayout];
	} else if ([keyPath isEqualToString:@"frame"]) {
		CGRect oldFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
		CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
		if (!CGPointEqualToPoint(oldFrame.origin,newFrame.origin)) {
			[self setNeedsLayout];
		}
	}
}



- (NSRect)NSViewFrame
{
	UIWindow *window = containerView.window;
	
	if (window) {
		const CGRect windowRect = [window convertRect:self.frame fromView:containerView];
		const CGRect screenRect = [window convertRect:windowRect toWindow:nil];
		return NSRectFromCGRect(screenRect);
	} else {
		return NSZeroRect;
	}
}

- (BOOL)createNSViewsIfNeeded
{
	if (!clipView && containerView.window) {
		const NSRect frame = self.NSViewFrame;

		clipView = [[UICustomNSClipView alloc] initWithFrame:frame];
		[clipView setWantsLayer:YES];
		[clipView setLayerParent:self];
		
		textView = [[UICustomNSTextView alloc] initWithFrame:NSMakeRect(0,0,frame.size.width,frame.size.height) secureTextEntry:secureTextEntry];
		[[textView layoutManager] replaceTextStorage:textStorage];
		[textView setWantsLayer:YES];
		[textView setEditable:editable];
		[textView setFont:[font _NSFont]];
		[textView setTextColor:[textColor _NSColor]];
		[textView sizeToFit];
		
		[clipView setDocumentView:textView];
		[clipView scrollToPoint:NSPointFromCGPoint([containerView contentOffset])];
		
		[[containerView.window.screen _NSView] addSubview:clipView];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScrollViewContentOffset) name:NSViewBoundsDidChangeNotification object:clipView];
		
		[self buildHierarchyObservers];

		return YES;
	} else {
		return NO;
	}
}

- (void)destroyNSViewsIfNeeded
{
	if (clipView) {
		[self removeHierarchyObservers];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:nil];
		[clipView removeFromSuperview];
		[clipView release];
		[textView release];
		clipView = nil;
		textView = nil;
	}
}

// Need to prevent Core Animation effects from happening... very ugly otherwise.
- (id < CAAction >)actionForKey:(NSString *)aKey
{
	return nil;
}

- (void)layoutSublayers
{
	if (containerView.window) {
		if (![self createNSViewsIfNeeded]) {
			[clipView setFrame:self.NSViewFrame];
		}
		// update the content size in the UIScrollView
		NSRect docRect = [clipView documentRect];
		[containerView setContentSize:CGSizeMake(docRect.size.width+docRect.origin.x, docRect.size.height+docRect.origin.y)];
	} else {
		[self destroyNSViewsIfNeeded];
	}

	[super layoutSublayers];
}

- (void)setContentOffset:(CGPoint)contentOffset
{
	NSPoint point = [clipView constrainScrollPoint:NSPointFromCGPoint(contentOffset)];
	[clipView scrollToPoint:point];
}

- (void)updateScrollViewContentOffset
{
	[containerView setContentOffset:NSPointToCGPoint([clipView bounds].origin)];
}

- (void)removeFromSuperlayer
{
	[self destroyNSViewsIfNeeded];
	[super removeFromSuperlayer];
}

- (void)setFont:(UIFont *)newFont
{
	NSAssert((newFont != nil), nil);
	if (newFont != font) {
		[font release];
		font = [newFont retain];
		[textView setFont:[font _NSFont]];
	}
}

- (void)setTextColor:(UIColor *)newColor
{
	if (newColor != textColor) {
		[textColor release];
		textColor = [newColor retain];
		[textView setTextColor:[textColor _NSColor]];
	}
}

- (NSString *)text
{
	return [[[textStorage mutableString] copy] autorelease];
}

- (void)setText:(NSString *)newText
{
	[textStorage setAttributedString:[[[NSAttributedString alloc] initWithString:newText] autorelease]];
}

- (void)setSecureTextEntry:(BOOL)s
{
	if (s != secureTextEntry) {
		secureTextEntry = s;
		[textView setSecureTextEntry:secureTextEntry];
	}
}

- (void)setEditable:(BOOL)edit
{
	if (editable != edit) {
		editable = edit;
		[textView setEditable:editable];
	}
}

- (void)setHidden:(BOOL)hide
{
	if (hide != self.hidden) {
		if (hide) {
			[self destroyNSViewsIfNeeded];
		} else {
			[self createNSViewsIfNeeded];
		}
		[super setHidden:hide];
	}
}

@end
