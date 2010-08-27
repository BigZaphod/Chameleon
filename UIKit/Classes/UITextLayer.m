//  Created by Sean Heber on 8/26/10.
#import "UITextLayer.h"
#import "UIScrollView.h"
#import "UICustomNSTextView.h"
#import "UICustomNSClipView.h"
#import "UIWindow.h"
#import "UIScreen+UIPrivate.h"
#import "UIColor+UIPrivate.h"
#import "UIFont+UIPrivate.h"
#import "UIView+UIPrivate.h"
#import <AppKit/NSLayoutManager.h>

@interface UITextLayer () <UICustomNSClipViewDelegate>
- (void)removeNSView;
@end

@implementation UITextLayer
@synthesize textColor, font, editable, secureTextEntry;

- (id)initWithContainerView:(id)aView
{
	if ((self=[super init])) {
		self.geometryFlipped = YES;
		self.masksToBounds = NO;
		containerView = aView;

		clipView = [[UICustomNSClipView alloc] initWithFrame:NSMakeRect(0,0,100,100) layerParent:self hitDelegate:self];
		textView = [[UICustomNSTextView alloc] initWithFrame:[clipView frame] secureTextEntry:secureTextEntry];
		[clipView setDocumentView:textView];
		
		[self setNeedsLayout];
	}
	return self;
}

- (void)dealloc
{
	[self removeNSView];
	[clipView release];
	[textView release];
	[textColor release];
	[font release];
	[super dealloc];
}


// Need to prevent Core Animation effects from happening... very ugly otherwise.
- (id < CAAction >)actionForKey:(NSString *)aKey
{
	return nil;
}

- (void)addNSView
{
	[clipView scrollToPoint:NSPointFromCGPoint([containerView contentOffset])];
	[[containerView.window.screen _NSView] addSubview:clipView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScrollViewContentOffset) name:NSViewBoundsDidChangeNotification object:clipView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hierarchyDidChangeNotification:) name:UIViewFrameDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hierarchyDidChangeNotification:) name:UIViewDidMoveToSuperviewNotification object:nil];
}

- (void)removeNSView
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:clipView];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIViewFrameDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIViewDidMoveToSuperviewNotification object:nil];
	[clipView removeFromSuperview];
}

- (BOOL)shouldBeVisible
{
	return (containerView.window && (self.superlayer == containerView.layer) && !self.hidden && !containerView.hidden);
}

- (void)updateNSViews
{
	if ([self shouldBeVisible]) {
		if (![clipView superview]) {
			[self addNSView];
		}
		
		UIWindow *window = containerView.window;
		const CGRect windowRect = [window convertRect:self.frame fromView:containerView];
		const CGRect screenRect = [window convertRect:windowRect toWindow:nil];
		NSRect desiredFrame = NSRectFromCGRect(screenRect);

		[clipView setFrame:desiredFrame];

		// also update the content size in the UIScrollView
		const NSRect docRect = [clipView documentRect];
		[containerView setContentSize:CGSizeMake(docRect.size.width+docRect.origin.x, docRect.size.height+docRect.origin.y)];
	} else {
		[self removeNSView];
	}
}

- (void)layoutSublayers
{
	[self updateNSViews];
	[super layoutSublayers];
}

- (void)removeFromSuperlayer
{
	[super removeFromSuperlayer];
	[self updateNSViews];
}

- (void)setHidden:(BOOL)hide
{
	if (hide != self.hidden) {
		[super setHidden:hide];
		[self updateNSViews];
	}
}

- (void)hierarchyDidChangeNotification:(NSNotification *)note
{
	if ([containerView isDescendantOfView:[note object]]) {
		if ([self shouldBeVisible]) {
			[self setNeedsLayout];
		} else {
			[self removeNSView];
		}
	}
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
	return [textView string];
}

- (void)setText:(NSString *)newText
{
	[textView setString:newText ?: @""];
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


// this is used to fake out AppKit when the UIView that owns this layer/editor stuff is actually *behind* another UIView. Since the NSViews are
// technically above all of the UIViews, they'd normally capture all clicks no matter what might happen to be obscuring them. That would obviously
// be less than ideal. This makes it ideal. Awesome.
- (BOOL)hitTestForClipViewPoint:(NSPoint)point
{
	UIScreen *screen = containerView.window.screen;
	
	if (screen) {
		if (![[screen _NSView] isFlipped]) {
			point.y = screen.bounds.size.height - point.y - 1;
		}
		return (containerView == [containerView.window.screen _hitTest:point event:nil]);
	}

	return NO;
}

@end
