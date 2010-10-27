//  Created by Sean Heber on 5/28/10.
#import "UIScrollView+UIPrivate.h"
#import "UIView+UIPrivate.h"
#import "UIScroller.h"
#import "UIScreen+UIPrivate.h"
#import "UIWindow.h"
#import "UITouch.h"
#import "UIImageView.h"
#import "UIImage+UIPrivate.h"
#import <QuartzCore/QuartzCore.h>

@interface UIScrollView () <_UIScrollerDelegate>
@end

const CGFloat _UIScrollViewScrollerSize = 15;

@implementation UIScrollView
@synthesize contentOffset=_contentOffset, contentInset=_contentInset, scrollIndicatorInsets=_scrollIndicatorInsets, scrollEnabled=_scrollEnabled;
@synthesize showsHorizontalScrollIndicator=_showsHorizontalScrollIndicator, showsVerticalScrollIndicator=_showsVerticalScrollIndicator, contentSize=_contentSize;
@synthesize maximumZoomScale=_maximumZoomScale, minimumZoomScale=_minimumZoomScale, zoomScale=_zoomScale, scrollsToTop=_scrollsToTop;
@synthesize indicatorStyle=_indicatorStyle, delaysContentTouches=_delaysContentTouches, delegate=_delegate, pagingEnabled=_pagingEnabled;

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_verticalScroller = [[UIScroller alloc] initWithOrientation:_UIScrollerOrientationVertical];
		_verticalScroller.delegate = self;
		[self addSubview:_verticalScroller];

		_horizontalScroller = [[UIScroller alloc] initWithOrientation:_UIScrollerOrientationHorizontal];
		_horizontalScroller.delegate = self;
		[self addSubview:_horizontalScroller];
		
		_grabber = [[UIImageView alloc] initWithImage:[UIImage _frameworkImageNamed:@"<UIScrollView> grabber-dark.png"]];
		[self addSubview:_grabber];
		
		self.clipsToBounds = YES;
		self.scrollEnabled = YES;
		self.indicatorStyle = UIScrollViewIndicatorStyleDefault;
		self.showsVerticalScrollIndicator = YES;
		self.showsHorizontalScrollIndicator = YES;
		self.scrollsToTop = YES;
		self.delaysContentTouches = YES;
		self.pagingEnabled = NO;
	}
	return self;
}

- (void)dealloc
{
	[_verticalScroller release];
	[_horizontalScroller release];
	[_grabber release];
	[super dealloc];
}

- (void)setDelegate:(id)newDelegate
{
	_delegate = newDelegate;
	_delegateCan.scrollViewDidScroll = [_delegate respondsToSelector:@selector(scrollViewDidScroll:)];
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

- (void)_setContentPositionAnimated:(BOOL)animated
{
	const BOOL wasAnimating = [UIView areAnimationsEnabled];
	[UIView setAnimationsEnabled:animated];
	if (animated) {
		[UIView beginAnimations:@"setContent" context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.1];
	}

	CGRect bounds = self.bounds;
	bounds.origin = CGPointMake(_contentOffset.x+_contentInset.left, _contentOffset.y+_contentInset.top);
	self.bounds = bounds;
	
	if (animated) {
		[UIView commitAnimations];
	}
	[UIView setAnimationsEnabled:wasAnimating];
}

- (void)_constrainContentOffset:(BOOL)animated
{
	const CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, _contentInset);

	if ((_contentSize.width-_contentOffset.x) < bounds.size.width) {
		_contentOffset.x = (_contentSize.width - bounds.size.width);
	}

	if ((_contentSize.height-_contentOffset.y) < bounds.size.height) {
		_contentOffset.y = (_contentSize.height - bounds.size.height);
	}

	_contentOffset.x = MAX(roundf(_contentOffset.x),0);
	_contentOffset.y = MAX(roundf(_contentOffset.y),0);

	if (_contentSize.width <= bounds.size.width) {
		_contentOffset.x = 0;
	}

	if (_contentSize.height <= bounds.size.height) {
		_contentOffset.y = 0;
	}

	_verticalScroller.contentSize = _contentSize.height - (self._canScrollHorizontal? _UIScrollViewScrollerSize : 0);
	_verticalScroller.contentOffset = _contentOffset.y;
	_horizontalScroller.contentSize = _contentSize.width - (self._canScrollVertical? _UIScrollViewScrollerSize : 0);
	_horizontalScroller.contentOffset = _contentOffset.x;

	[self _setContentPositionAnimated:animated];
}

- (BOOL)_shouldShowGrabber
{
	const BOOL showingHorizontal = self._canScrollHorizontal;
	const BOOL showingVertical = self._canScrollVertical;
	const BOOL showingBothScrollers = showingVertical && showingHorizontal;
	if (showingBothScrollers) {
		return YES;
	} else if (showingVertical || showingHorizontal) {
		UIWindow *window = self.window;
		UIScreen *screen = window.screen;
		const CGRect screenBounds = screen.bounds;
		const CGPoint bottomRightScreenPoint = CGPointMake(screenBounds.origin.x+screenBounds.size.width, screenBounds.origin.y+screenBounds.size.height);
		const CGRect selfBounds = self.bounds;
		const CGPoint bottomRightViewPoint = CGPointMake(selfBounds.origin.x+selfBounds.size.width, selfBounds.origin.y+selfBounds.size.height);
		const CGPoint viewBottomRightScreenPoint = [window convertPoint:[self convertPoint:bottomRightViewPoint toView:window] toWindow:nil];
		const BOOL viewAtBottomRightOfScreen = CGPointEqualToPoint(viewBottomRightScreenPoint, bottomRightScreenPoint);
		return (viewAtBottomRightOfScreen && [screen _hasResizeIndicator]);
	} else {
		return NO;
	}
}

- (void)_updateScrollers
{
	[self _constrainContentOffset:NO];
	
	const BOOL showingGrabber = [self _shouldShowGrabber];
	
	const CGRect bounds = self.bounds;
	_verticalScroller.frame = CGRectMake(bounds.origin.x+bounds.size.width-_UIScrollViewScrollerSize-_scrollIndicatorInsets.right,bounds.origin.y+_scrollIndicatorInsets.top,_UIScrollViewScrollerSize,bounds.size.height-(showingGrabber? _UIScrollViewScrollerSize : 0)-_scrollIndicatorInsets.top-_scrollIndicatorInsets.bottom);
	_horizontalScroller.frame = CGRectMake(bounds.origin.x+_scrollIndicatorInsets.left,bounds.origin.y+bounds.size.height-_UIScrollViewScrollerSize-_scrollIndicatorInsets.bottom,bounds.size.width-(showingGrabber? _UIScrollViewScrollerSize : 0)-_scrollIndicatorInsets.left-_scrollIndicatorInsets.right,_UIScrollViewScrollerSize);
	_grabber.frame = CGRectMake(bounds.origin.x+bounds.size.width-_UIScrollViewScrollerSize-_scrollIndicatorInsets.right,bounds.origin.y+bounds.size.height-_UIScrollViewScrollerSize-_scrollIndicatorInsets.bottom,_UIScrollViewScrollerSize,_UIScrollViewScrollerSize);
	_grabber.hidden = !showingGrabber;
	_verticalScroller.hidden = !self._canScrollVertical;
	_horizontalScroller.hidden = !self._canScrollHorizontal;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self _updateScrollers];
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	[self _updateScrollers];
}

- (void)_bringScrollersToFront
{
	[super bringSubviewToFront:_horizontalScroller];
	[super bringSubviewToFront:_verticalScroller];
	[super bringSubviewToFront:_grabber];
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

- (void)setContentOffset:(CGPoint)theOffset animated:(BOOL)animated
{
	_contentOffset = theOffset;
	[self _constrainContentOffset:animated];
	[self _updateScrollers];
	if (_delegateCan.scrollViewDidScroll) {
		[_delegate scrollViewDidScroll:self];
	}
}

- (void)setContentOffset:(CGPoint)theOffset
{
	[self setContentOffset:theOffset animated:NO];
}

- (void)setContentSize:(CGSize)newSize
{
	if (!CGSizeEqualToSize(newSize, _contentSize)) {
		_contentSize = newSize;
		[self _updateScrollers];
	}
}

- (BOOL)isDragging
{
	return (_draggingScroller != nil);
}

- (void)scrollWheelMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
	if (self.scrollEnabled) {
		// Increasing the delta because it just seems to feel better to me right now.
		// Dunno if this is something standard that OSX is doing or if OSX actually scales it somehow based on content size.
		delta.x *= 10.f;
		delta.y *= 10.f;

		CGPoint offset = self.contentOffset;
		offset.x -= delta.x;
		offset.y -= delta.y;
		[self setContentOffset:offset animated:NO];	// setting YES here is a lot nicer/smoother, but the scrollbars get all messed up. Need to figure that out.
	}
}

- (void)_UIScroller:(UIScroller *)scroller contentOffsetDidChange:(CGFloat)newOffset
{
	if (self.scrollEnabled) {
		if (scroller == _verticalScroller) {
			[self setContentOffset:CGPointMake(self.contentOffset.x,newOffset) animated:NO];
		} else if (scroller == _horizontalScroller) {
			[self setContentOffset:CGPointMake(newOffset,self.contentOffset.y) animated:NO];
		}
	}
}

- (void)flashScrollIndicators
{
}

- (void)setZoomScale:(float)scale animated:(BOOL)animated
{
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

@end
