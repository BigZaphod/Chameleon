//  Created by Sean Heber on 8/26/10.
#import "UICustomNSClipView.h"
#import <AppKit/NSEvent.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CATransaction.h>

@implementation UICustomNSClipView

- (id)initWithFrame:(NSRect)frame layerParent:(CALayer *)layer behaviorDelegate:(id<UICustomNSClipViewBehaviorDelegate>)aBehaviorDelegate
{
	if ((self=[super initWithFrame:frame])) {
		parentLayer = layer;
		behaviorDelegate = aBehaviorDelegate;
		[self setDrawsBackground:NO];
		[self setWantsLayer:YES];
	}
	return self;
}

- (void)scrollWheel:(NSEvent *)event
{
	if ([behaviorDelegate clipViewShouldScroll]) {
		NSPoint offset = [self bounds].origin;
		offset.x += [event deltaX];
		offset.y -= [event deltaY];
		[self scrollToPoint:[self constrainScrollPoint:offset]];
	}
}

- (void)fixupTheLayer
{
	if ([self superview]) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
		
		CALayer *layer = [self layer];

		if (parentLayer != layer.superlayer) {
			[parentLayer addSublayer:layer];
		}
		
		if (!CGRectEqualToRect(layer.frame, parentLayer.bounds)) {
			layer.frame = parentLayer.bounds;
		}
		
		[CATransaction commit];
	}
}

- (void)viewDidMoveToSuperview
{
	[super viewDidMoveToSuperview];
	[self fixupTheLayer];
}

- (void)viewWillDraw
{
	[super viewWillDraw];
	[self fixupTheLayer];
}

- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
	[self fixupTheLayer];
}

- (void)viewDidUnhide
{
	[super viewDidUnhide];
	[self fixupTheLayer];
}

- (NSView *)hitTest:(NSPoint)aPoint
{
	NSView *hit = [super hitTest:aPoint];

	if (hit && behaviorDelegate) {
		// call out to the text layer via a delegate or something and ask if this point should be considered a hit or not.
		// if not, then we set hit to nil, otherwise we return it like normal.
		// the purpose of this is to make the NSView act invisible/hidden to clicks when it's visually behind other UIViews.
		// super tricky, eh?
		if (![behaviorDelegate hitTestForClipViewPoint:aPoint]) {
			hit = nil;
		}
	}

	return hit;
}

@end
