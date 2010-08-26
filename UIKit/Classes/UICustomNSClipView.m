//  Created by Sean Heber on 8/26/10.
#import "UICustomNSClipView.h"
#import <AppKit/NSEvent.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CATransaction.h>

@implementation UICustomNSClipView

- (id)initWithFrame:(NSRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		[self setDrawsBackground:NO];
	}
	return self;
}

- (void)scrollWheel:(NSEvent *)event
{
	NSPoint offset = [self bounds].origin;
	offset.x += [event deltaX];
	offset.y -= [event deltaY];
	[self scrollToPoint:[self constrainScrollPoint:offset]];
}

- (void)fixupTheLayer
{
	[CATransaction begin];
	[CATransaction setAnimationDuration:0];
	[parentLayer addSublayer:[self layer]];
	[self layer].frame = parentLayer.bounds;
	[CATransaction commit];
}

- (void)setLayerParent:(CALayer *)layer
{
	parentLayer = layer;
	[self fixupTheLayer];
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

@end
