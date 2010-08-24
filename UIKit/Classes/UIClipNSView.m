//  Created by Sean Heber on 8/23/10.
#import "UIClipNSView.h"
#import "UIView.h"
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CATransaction.h>

@implementation UIClipNSView
- (void)setContainerView:(UIView *)view
{
	containerView = view;
}

- (void)updateLayer
{
	[CATransaction begin];
	[CATransaction setAnimationDuration:0];
	[containerView.layer insertSublayer:[self layer] atIndex:0];
	[[self layer] setFrame:containerView.bounds];
	[CATransaction commit];
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize
{
	NSLog( @"resizeWithOldSuperviewSize" );
	[super resizeWithOldSuperviewSize:oldBoundsSize];
	[self updateLayer];
}

- (void)viewDidMoveToSuperview
{
	NSLog( @"viewDidMoveToSuperview" );
	[super viewDidMoveToSuperview];
	[self updateLayer];
}

- (void)setFrame:(NSRect)frame
{
	NSLog( @"setFrame" );
	[super setFrame:frame];
	[self updateLayer];
}

 - (void)setBounds:(NSRect)bounds
 {
 NSLog( @"setBounds" );
 [super setBounds:bounds];
 }
 
 - (void)scrollClipView:(NSClipView *)aClipView toPoint:(NSPoint)newOrigin
 {
 NSLog( @"scrollClipView:toPoint" );
 [super scrollClipView:aClipView toPoint:newOrigin];
 }
 
 - (void)scrollPoint:(NSPoint)aPoint
 {
 NSLog( @"scrollPoint" );
 [super scrollPoint:aPoint];
 }
 
 - (BOOL)scrollRectToVisible:(NSRect)aRect
 {
 NSLog( @"scrollRectToVisible" );
 return [super scrollRectToVisible:aRect];
 }
 
 - (void)reflectScrolledClipView:(NSClipView *)aClipView
 {
 NSLog( @"reflectScrolledClipView" );
 [super reflectScrolledClipView:aClipView];
 }
 
 - (void)scrollRect:(NSRect)aRect by:(NSSize)offset
 {
 NSLog( @"scrollRect:by:" );
 [super scrollRect:aRect by:offset];
 }
 
 - (NSPoint)constrainScrollPoint:(NSPoint)proposedNewOrigin
 {
 NSLog( @"constrainScrollPoint" );
 return [super constrainScrollPoint:proposedNewOrigin];
 }

- (void)scrollToPoint:(NSPoint)newOrigin
{
	NSLog( @"scrollToPoint" );
	[super scrollToPoint:newOrigin];
	[self updateLayer];
}

@end
