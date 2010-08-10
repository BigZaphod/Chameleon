//  Created by Sean Heber on 5/28/10.
#import "UIScrollView.h"
#import "_UIScroller.h"
#import "UITouch.h"
#import "UIImageView.h"
#import "UIImage.h"
#import "UIKit+Private.h"
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
		_verticalScroller = [[_UIScroller alloc] initWithOrientation:_UIScrollerOrientationVertical];
		_verticalScroller.delegate = self;
		[self addSubview:_verticalScroller];

		_horizontalScroller = [[_UIScroller alloc] initWithOrientation:_UIScrollerOrientationHorizontal];
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
	return self.scrollEnabled && self.showsHorizontalScrollIndicator;
}

- (BOOL)_canScrollVertical
{
	return self.scrollEnabled && self.showsVerticalScrollIndicator;
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
	const BOOL showingBothScrollers = (self._canScrollHorizontal && self._canScrollVertical);
	if (showingBothScrollers) {
		return YES;
	} else {
		UIWindow *window = self.window;
		UIScreen *screen = window.screen;
		const CGRect screenBounds = screen.bounds;
		const CGPoint bottomRightScreenPoint = CGPointMake(screenBounds.origin.x+screenBounds.size.width, screenBounds.origin.y+screenBounds.size.height);
		const CGRect selfBounds = self.bounds;
		const CGPoint bottomRightViewPoint = CGPointMake(selfBounds.origin.x+selfBounds.size.width, selfBounds.origin.y+selfBounds.size.height);
		const CGPoint viewBottomRightScreenPoint = [window convertPoint:[self convertPoint:bottomRightViewPoint toView:window] toWindow:nil];
		const BOOL viewAtBottomRightOfScreen = CGPointEqualToPoint(viewBottomRightScreenPoint, bottomRightScreenPoint);
		return (viewAtBottomRightOfScreen && [screen _hasResizeIndicator]);
	}
}

- (void)_layoutSubviews
{
	[super _layoutSubviews];

	[self _constrainContentOffset:NO];

	const BOOL showingGrabber = [self _shouldShowGrabber];
	
	const CGRect bounds = self.bounds;
	_verticalScroller.frame = CGRectMake(bounds.origin.x+bounds.size.width-_UIScrollViewScrollerSize-_scrollIndicatorInsets.right,bounds.origin.y+_scrollIndicatorInsets.top,_UIScrollViewScrollerSize,bounds.size.height-(showingGrabber? _UIScrollViewScrollerSize : 0)-_scrollIndicatorInsets.top-_scrollIndicatorInsets.bottom);
	_horizontalScroller.frame = CGRectMake(bounds.origin.x+_scrollIndicatorInsets.left,bounds.origin.y+bounds.size.height-_UIScrollViewScrollerSize-_scrollIndicatorInsets.bottom,bounds.size.width-(showingGrabber? _UIScrollViewScrollerSize : 0)-_scrollIndicatorInsets.left-_scrollIndicatorInsets.right,_UIScrollViewScrollerSize);
	_grabber.frame = CGRectMake(bounds.origin.x+bounds.size.width-_UIScrollViewScrollerSize-_scrollIndicatorInsets.right,bounds.origin.y+bounds.size.height-_UIScrollViewScrollerSize-_scrollIndicatorInsets.bottom,_UIScrollViewScrollerSize,_UIScrollViewScrollerSize);
	_grabber.hidden = !showingGrabber;
	_verticalScroller.hidden = !self._canScrollVertical;
	_horizontalScroller.hidden = !self._canScrollHorizontal;

	[self bringSubviewToFront:_horizontalScroller];
	[self bringSubviewToFront:_verticalScroller];
	[self bringSubviewToFront:_grabber];
}

- (void)setContentOffset:(CGPoint)theOffset animated:(BOOL)animated
{
	_contentOffset = theOffset;
	[self _constrainContentOffset:animated];
}

- (void)setContentOffset:(CGPoint)theOffset
{
	[self setContentOffset:theOffset animated:NO];
}

- (BOOL)isDragging
{
	return (_draggingScroller != nil);
}

- (void)scrollWheelMoved:(NSValue *)deltaValue withEvent:(UIEvent *)event
{
	if (self.scrollEnabled) {
		CGPoint delta = [deltaValue CGPointValue];
		
		// Increasing the delta because it just seems to feel better to me right now.
		// Dunno if this is something standard that OSX is doing or if OSX actually scales it somehow based on content size.
		delta.x *= 2.5f;
		delta.y *= 2.5f;

		CGPoint offset = self.contentOffset;
		offset.x -= delta.x;
		offset.y -= delta.y;
		[self setContentOffset:offset animated:NO];	// setting YES here is a lot nicer/smoother, but the scrollbars get all messed up. Need to figure that out.
	}
}

- (void)_UIScroller:(_UIScroller *)scroller contentOffsetDidChange:(CGFloat)newOffset
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
@end
