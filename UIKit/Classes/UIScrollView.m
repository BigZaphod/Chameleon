//  Created by Sean Heber on 5/28/10.
#import "UIScrollView.h"
#import "UIView+UIPrivate.h"
#import "UIScroller.h"
#import "UIScreen+UIPrivate.h"
#import "UIWindow.h"
#import "UITouch.h"
#import "UIImageView.h"
#import "UIImage+UIPrivate.h"
#import "UIResponderAppKitIntegration.h"
#import <QuartzCore/QuartzCore.h>

const NSTimeInterval UIScrollViewAnimationDuration = 0.33;

static CGFloat UIScrollerWidthForBoundsSize(CGSize boundsSize)
{
	const CGFloat minViewSize = 50;
	
	if (boundsSize.width <= minViewSize || boundsSize.height <= minViewSize) {
		return 6;
	} else {
		return 10;
	}
}

@interface UIScrollView () <_UIScrollerDelegate>
@end

@implementation UIScrollView
@synthesize contentOffset=_contentOffset, contentInset=_contentInset, scrollIndicatorInsets=_scrollIndicatorInsets, scrollEnabled=_scrollEnabled;
@synthesize showsHorizontalScrollIndicator=_showsHorizontalScrollIndicator, showsVerticalScrollIndicator=_showsVerticalScrollIndicator, contentSize=_contentSize;
@synthesize maximumZoomScale=_maximumZoomScale, minimumZoomScale=_minimumZoomScale, scrollsToTop=_scrollsToTop;
@synthesize indicatorStyle=_indicatorStyle, delaysContentTouches=_delaysContentTouches, delegate=_delegate, pagingEnabled=_pagingEnabled;
@synthesize canCancelContentTouches=_canCancelContentTouches, bouncesZoom=_bouncesZoom, zooming=_zooming;

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_scrollEnabled = YES;
		_indicatorStyle = UIScrollViewIndicatorStyleDefault;
		_showsVerticalScrollIndicator = YES;
		_showsHorizontalScrollIndicator = YES;
		_scrollsToTop = YES;
		_delaysContentTouches = YES;
		_canCancelContentTouches = YES;
		_pagingEnabled = NO;
		_bouncesZoom = NO;
		_maximumZoomScale = 1;
		_minimumZoomScale = 1;

		_verticalScroller = [[UIScroller alloc] init];
		_verticalScroller.delegate = self;
		[self addSubview:_verticalScroller];

		_horizontalScroller = [[UIScroller alloc] init];
		_horizontalScroller.delegate = self;
		[self addSubview:_horizontalScroller];
		
		self.clipsToBounds = YES;
	}
	return self;
}

- (void)dealloc
{
	[_verticalScroller release];
	[_horizontalScroller release];
	[super dealloc];
}

- (void)setDelegate:(id)newDelegate
{
	_delegate = newDelegate;
	_delegateCan.scrollViewDidScroll = [_delegate respondsToSelector:@selector(scrollViewDidScroll:)];
	_delegateCan.scrollViewWillBeginDragging = [_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)];
	_delegateCan.scrollViewDidEndDragging = [_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)];
	_delegateCan.viewForZoomingInScrollView = [_delegate respondsToSelector:@selector(viewForZoomingInScrollView:)];
	_delegateCan.scrollViewWillBeginZooming = [_delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)];
	_delegateCan.scrollViewDidEndZooming = [_delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)];
	_delegateCan.scrollViewDidZoom = [_delegate respondsToSelector:@selector(scrollViewDidZoom:)];
}

- (UIView *)_zoomingView
{
	return (_delegateCan.viewForZoomingInScrollView)? [_delegate viewForZoomingInScrollView:self] : nil;
}

- (void)setIndicatorStyle:(UIScrollViewIndicatorStyle)style
{
	_indicatorStyle = style;
	_horizontalScroller.indicatorStyle = style;
	_verticalScroller.indicatorStyle = style;
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)show
{
	_showsHorizontalScrollIndicator = show;
	[self setNeedsLayout];
}

- (void)setShowsVerticalScrollIndicator:(BOOL)show
{
	_showsVerticalScrollIndicator = show;
	[self setNeedsLayout];
}

- (void)setScrollEnabled:(BOOL)enabled
{
	_scrollEnabled = enabled;
	[self setNeedsLayout];
}

- (BOOL)_canScrollHorizontal
{
	return self.scrollEnabled && self.showsHorizontalScrollIndicator && (_contentSize.width > self.bounds.size.width);
}

- (BOOL)_canScrollVertical
{
	return self.scrollEnabled && self.showsVerticalScrollIndicator && (_contentSize.height > self.bounds.size.height);
}

- (void)_constrainContent
{
	const CGRect scrollerBounds = UIEdgeInsetsInsetRect(self.bounds, _contentInset);
	
	if ((_contentSize.width-_contentOffset.x) < scrollerBounds.size.width) {
		_contentOffset.x = (_contentSize.width - scrollerBounds.size.width);
	}
	
	if ((_contentSize.height-_contentOffset.y) < scrollerBounds.size.height) {
		_contentOffset.y = (_contentSize.height - scrollerBounds.size.height);
	}
	
	_contentOffset.x = MAX(roundf(_contentOffset.x),0);
	_contentOffset.y = MAX(roundf(_contentOffset.y),0);
	
	if (_contentSize.width <= scrollerBounds.size.width) {
		_contentOffset.x = 0;
	}
	
	if (_contentSize.height <= scrollerBounds.size.height) {
		_contentOffset.y = 0;
	}
	
	_verticalScroller.contentSize = _contentSize.height;
	_verticalScroller.contentOffset = _contentOffset.y;
	_horizontalScroller.contentSize = _contentSize.width;
	_horizontalScroller.contentOffset = _contentOffset.x;
	
	_verticalScroller.hidden = !self._canScrollVertical;
	_horizontalScroller.hidden = !self._canScrollHorizontal;
	
	CGRect bounds = self.bounds;
	bounds.origin = CGPointMake(_contentOffset.x+_contentInset.left, _contentOffset.y+_contentInset.top);
	self.bounds = bounds;
	
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	const CGRect bounds = self.bounds;
	const CGFloat scrollerSize = UIScrollerWidthForBoundsSize(bounds.size);
	
	_verticalScroller.frame = CGRectMake(bounds.origin.x+bounds.size.width-scrollerSize-_scrollIndicatorInsets.right,bounds.origin.y+_scrollIndicatorInsets.top,scrollerSize,bounds.size.height-_scrollIndicatorInsets.top-_scrollIndicatorInsets.bottom);
	_horizontalScroller.frame = CGRectMake(bounds.origin.x+_scrollIndicatorInsets.left,bounds.origin.y+bounds.size.height-scrollerSize-_scrollIndicatorInsets.bottom,bounds.size.width-_scrollIndicatorInsets.left-_scrollIndicatorInsets.right,scrollerSize);
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self _constrainContent];
}

- (void)_bringScrollersToFront
{
	[super bringSubviewToFront:_horizontalScroller];
	[super bringSubviewToFront:_verticalScroller];
}

- (void)addSubview:(UIView *)subview
{
	[super addSubview:subview];
	[self _bringScrollersToFront];
}

- (void)bringSubviewToFront:(UIView *)subview
{
	[super bringSubviewToFront:subview];
	[self _bringScrollersToFront];
}

- (void)insertSubview:(UIView *)subview atIndex:(NSInteger)index
{
	[super insertSubview:subview atIndex:index];
	[self _bringScrollersToFront];
}

- (void)_scrollContentOffsetBy:(NSValue *)d
{
	const CGPoint delta = [d CGPointValue];
	CGPoint offset = self.contentOffset;
	offset.x -= delta.x;
	offset.y -= delta.y;
	self.contentOffset = offset;
}

- (void)_scrollContentOffsetBy:(CGPoint)delta withAnimationDuration:(NSTimeInterval)animationDuration
{
	const NSInteger framesPerSecond = 60;
	const NSInteger numberOfFrames = animationDuration * framesPerSecond;
	const NSTimeInterval timePerFrame = animationDuration/(NSTimeInterval)numberOfFrames;
	const CGPoint frameDelta = CGPointMake(delta.x/(float)numberOfFrames, delta.y/(float)numberOfFrames);
	
	for (NSInteger f=0; f<numberOfFrames; f++) {
		[self performSelector:@selector(_scrollContentOffsetBy:) withObject:[NSValue valueWithCGPoint:frameDelta] afterDelay:(f * timePerFrame)];
	}
}

- (void)setContentOffset:(CGPoint)theOffset animated:(BOOL)animated
{
	if (animated) {
		[self _scrollContentOffsetBy:CGPointMake(_contentOffset.x-theOffset.x, _contentOffset.y-theOffset.y) withAnimationDuration:UIScrollViewAnimationDuration];
	} else {
		[self setContentOffset:theOffset];
	}
}

- (void)setContentOffset:(CGPoint)theOffset
{
	if (! CGPointEqualToPoint(_contentOffset, theOffset)) {
		_contentOffset = theOffset;
		[self _constrainContent];
		
		if (_delegateCan.scrollViewDidScroll) {
			[_delegate scrollViewDidScroll:self];
		}
	}
}

- (void)setContentSize:(CGSize)newSize
{
	if (!CGSizeEqualToSize(newSize, _contentSize)) {
		_contentSize = newSize;
		[self _constrainContent];
	}
}

- (void)flashScrollIndicators
{
	[_horizontalScroller flash];
	[_verticalScroller flash];
}

- (void)_quickFlashScrollIndicators
{
	[_horizontalScroller quickFlash];
	[_verticalScroller quickFlash];
}

- (void)_delegateDraggingDidBegin
{
	if (!_dragDelegateTimer) {
		if (_delegateCan.scrollViewWillBeginDragging) {
			[_delegate scrollViewWillBeginDragging:self];
		}
	}
	
	[_dragDelegateTimer invalidate];
	_dragDelegateTimer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(_delegateDraggingDidEnd) userInfo:nil repeats:NO];
}

- (void)removeFromSuperview
{
	// there's a rare case where the deferment of the draggingDidEnd message can cause a crash indirectly because it ends up that the scroll view's delegate
	// was destroyed and the only thing keeping the scrollview itself alive is the NSTimer holding on to it for this. That means that when the timer fires,
	// it tries to send a message to the now-deceased delegate object and BOOM goes the app. This seems like a hacky work around to this. Technically,
	// anything that wants to be a delegate of the scroll view should be making sure it's living at least as long as the scroll view itself, or set the
	// scroll view's delegate to nil before it pops off and dies. So in some respects, this isn't *exactly* a bug in UIKit but it is happening often enough
	// and the fact that this is a deferred thing which is not how the real UIKit works makes me think we have to try to work around it here in this case. :/
	// The reasoning for invalidating the timer here is similar to the reasoning in UIView's removeFromSuperview which cancels any active touches on the view
	// just before it's removed. This sort of falls into the same category in that this is kind of like a fake touch. If it weren't implemented via a timer
	// then the touching canceling that happens in UIView's removeFromSuperview would ultimately have the same effect here - it'd never get a touchesEnded:
	// message and thus I'd assume there'd be no sending of draggingDidEnd, either.
	[_dragDelegateTimer invalidate];
	_dragDelegateTimer = nil;

	[super removeFromSuperview];
}

- (BOOL)isDragging
{
	return (_dragDelegateTimer != nil);
}

- (void)_delegateDraggingDidEnd
{
	_dragDelegateTimer = nil;

	if (_delegateCan.scrollViewDidEndDragging) {
		[_delegate scrollViewDidEndDragging:self willDecelerate:NO];
	}
}

- (void)mouseMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	const CGPoint point = [touch locationInView:self];
	const CGFloat scrollerSize = UIScrollerWidthForBoundsSize(self.bounds.size);
	
	_horizontalScroller.alwaysVisible = CGRectContainsPoint(CGRectInset(_horizontalScroller.frame, -scrollerSize, -scrollerSize), point);
	_verticalScroller.alwaysVisible = CGRectContainsPoint(CGRectInset(_verticalScroller.frame, -scrollerSize, -scrollerSize), point);
	
	[super mouseMoved:delta withEvent:event];
}

- (void)mouseExitedView:(UIView *)exited enteredView:(UIView *)entered withEvent:(UIEvent *)event
{
	if ([exited isDescendantOfView:self] && ![entered isDescendantOfView:self]) {
		_horizontalScroller.alwaysVisible = NO;
		_verticalScroller.alwaysVisible = NO;
	}
	
	[super mouseExitedView:exited enteredView:entered withEvent:event];
}

- (void)scrollWheelMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
	if (self.scrollEnabled) {
		[self _delegateDraggingDidBegin];

		// Increasing the delta because it just seems to feel better to me right now.
		// Dunno if this is something standard that OSX is doing or if OSX actually scales it somehow based on content size.
		delta.x *= 9.f;
		delta.y *= 9.f;
		
		[self _scrollContentOffsetBy:delta withAnimationDuration:0.09];
		[self _quickFlashScrollIndicators];
	} else {
		[super scrollWheelMoved:delta withEvent:event];
	}
}

- (void)_UIScroller:(UIScroller *)scroller contentOffsetDidChange:(CGFloat)newOffset
{
	if (self.scrollEnabled) {
		[self _delegateDraggingDidBegin];

		if (scroller == _verticalScroller) {
			[self setContentOffset:CGPointMake(self.contentOffset.x,newOffset) animated:NO];
		} else if (scroller == _horizontalScroller) {
			[self setContentOffset:CGPointMake(newOffset,self.contentOffset.y) animated:NO];
		}
	}
}

- (void)_UIScrollerDidEndDragging:(UIScroller *)scroller withEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	const CGPoint point = [touch locationInView:self];
	
	if (!CGRectContainsPoint(scroller.frame,point)) {
		scroller.alwaysVisible = NO;
	}
}

- (BOOL)isDecelerating
{
	return NO;
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
	const CGRect contentRect = CGRectMake(0,0,_contentSize.width, _contentSize.height);
	const CGRect visibleRect = self.bounds;
	CGRect goalRect = CGRectIntersection(rect, contentRect);

	if (!CGRectIsNull(goalRect) && !CGRectContainsRect(visibleRect, goalRect)) {
		
		// clamp the goal rect to the largest possible size for it given the visible space available
		// this causes it to prefer the top-left of the rect if the rect is too big
		goalRect.size.width = MIN(goalRect.size.width, visibleRect.size.width);
		goalRect.size.height = MIN(goalRect.size.height, visibleRect.size.height);
		
		CGPoint offset = self.contentOffset;
		
		if (CGRectGetMaxY(goalRect) > CGRectGetMaxY(visibleRect)) {
			offset.y += CGRectGetMaxY(goalRect) - CGRectGetMaxY(visibleRect);
		} else if (CGRectGetMinY(goalRect) < CGRectGetMinY(visibleRect)) {
			offset.y += CGRectGetMinY(goalRect) - CGRectGetMinY(visibleRect);
		}
		
		if (CGRectGetMaxX(goalRect) > CGRectGetMaxX(visibleRect)) {
			offset.x += CGRectGetMaxX(goalRect) - CGRectGetMaxX(visibleRect);
		} else if (CGRectGetMinX(goalRect) < CGRectGetMinX(visibleRect)) {
			offset.x += CGRectGetMinX(goalRect) - CGRectGetMinX(visibleRect);
		}
		
		[self setContentOffset:offset animated:animated];
	}
}

- (BOOL)isZoomBouncing
{
	return NO;
}

- (float)zoomScale
{
	UIView *zoomingView = [self _zoomingView];
	
	// it seems weird to return the "a" component of the transform for this, but after some messing around with the real UIKit, I'm
	// reasonably certain that's how it is doing it.
	return zoomingView? zoomingView.transform.a : 1.f;
}

- (void)setZoomScale:(float)scale animated:(BOOL)animated
{
	UIView *zoomingView = [self _zoomingView];
	scale = MIN(MAX(scale, _minimumZoomScale), _maximumZoomScale);

	if (zoomingView && self.zoomScale != scale) {
		if (animated) {
			[UIView beginAnimations:@"setZoomScale" context:NULL];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:UIScrollViewAnimationDuration];
		}

		zoomingView.transform = CGAffineTransformMakeScale(scale, scale);
		
		const CGSize size = zoomingView.frame.size;
		zoomingView.layer.position = CGPointMake(size.width/2.f, size.height/2.f);

		self.contentSize = size;
		
		if (animated) {
			[UIView commitAnimations];
		}
	}
}

- (void)setZoomScale:(float)scale
{
	[self setZoomScale:scale animated:NO];
}

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated
{
}

@end
