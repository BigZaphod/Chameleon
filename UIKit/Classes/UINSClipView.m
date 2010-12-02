//  Created by Sean Heber on 12/1/10.
#import "UINSClipView.h"
#import "UIScrollView+UIPrivate.h"
#import "UIWindow.h"
#import "UIScreen+UIPrivate.h"
#import "UIScreenAppKitIntegration.h"
#import <AppKit/NSEvent.h>


@implementation UINSClipView

- (id)initWithFrame:(NSRect)frame parentView:(UIScrollView *)aView
{
	if ((self=[super initWithFrame:frame])) {
		parentView = aView;
		[self setDrawsBackground:NO];
		[self setCopiesOnScroll:NO];
		[self setWantsLayer:YES];
		[self setAutoresizingMask:NSViewNotSizable];
	}
	return self;
}

- (BOOL)isFlipped
{
	return YES;
}

- (BOOL)isOpaque
{
	return NO;
}

- (void)scrollWheel:(NSEvent *)event
{
	if (parentView.scrollEnabled) {
		NSPoint offset = [self bounds].origin;
		offset.x -= [event deltaX];
		offset.y -= [event deltaY];
		
		[parentView _quickFlashScrollIndicators];
		[parentView setContentOffset:NSPointToCGPoint(offset) animated:NO];
	}
}

- (void)viewDidMoveToSuperview
{
	[super viewDidMoveToSuperview];
	[parentView setNeedsLayout];
}

- (void)viewWillDraw
{
	[parentView setNeedsLayout];
	[super viewWillDraw];
}

- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
	[parentView setNeedsLayout];
}

// this is used to fake out AppKit when the UIView that "owns" this NSView's layer is actually *behind* another UIView. Since the NSViews are
// technically above all of the UIViews, they'd normally capture all clicks no matter what might happen to be obscuring them. That would obviously
// be less than ideal. This makes it ideal. It is awesome.
- (NSView *)hitTest:(NSPoint)aPoint
{
	NSView *hitNSView = [super hitTest:aPoint];

	if (hitNSView) {
		UIScreen *screen = parentView.window.screen;
		BOOL didHitUIView = NO;
		
		if (screen) {
			if (![[screen UIKitView] isFlipped]) {
				aPoint.y = screen.bounds.size.height - aPoint.y - 1;
			}

			didHitUIView = (parentView == [screen _hitTest:NSPointToCGPoint(aPoint) event:nil]);
		}
		
		if (!didHitUIView) {
			hitNSView = nil;
		}
	}

	return hitNSView;
}

@end
