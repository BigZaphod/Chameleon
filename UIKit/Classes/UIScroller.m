//  Created by Sean Heber on 5/28/10.
#import "UIScroller.h"
#import "UITouch.h"
#import "UIBezierPath.h"
#import "UIColor.h"

static const BOOL _UIScrollerJumpToSpotThatIsClicked = NO;

@implementation UIScroller
@synthesize delegate=_delegate, contentOffset=_contentOffset, contentSize=_contentSize;
@synthesize indicatorStyle=_indicatorStyle, alwaysVisible=_alwaysVisible;

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		self.opaque = NO;
		self.alpha = 0;
		self.indicatorStyle = UIScrollViewIndicatorStyleDefault;
	}
	return self;
}

- (void)setFrame:(CGRect)frame
{
	_isVertical = (frame.size.height > frame.size.width);
	[super setFrame:frame];
}

- (void)_fadeOut
{
	[_fadeTimer invalidate];
	_fadeTimer = nil;
		
	[UIView beginAnimations:@"fadeOut" context:NULL];
	[UIView setAnimationDuration:0.33];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	self.alpha = 0;
	[UIView commitAnimations];
}

- (void)_fadeOutAfterDelay:(NSTimeInterval)time
{
	[_fadeTimer invalidate];
	_fadeTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(_fadeOut) userInfo:nil repeats:NO];
}

- (void)_fadeIn
{
	[_fadeTimer invalidate];
	_fadeTimer = nil;

	[UIView beginAnimations:@"fadeIn" context:NULL];
	[UIView setAnimationDuration:0.33];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	self.alpha = 1;
	[UIView commitAnimations];
}

- (void)flash
{
	if (!_alwaysVisible) {
		[self _fadeIn];
		[self _fadeOutAfterDelay:1.5];
	}
}

- (void)quickFlash
{
	if (!_alwaysVisible) {
		self.alpha = 1;
		[self _fadeOutAfterDelay:0.5];
	}
}

- (void)setAlwaysVisible:(BOOL)v
{
	_alwaysVisible = v;

	if (_alwaysVisible) {
		[self _fadeIn];
	} else if (self.alpha > 0) {
		[self _fadeOut];
	}
}

- (void)setIndicatorStyle:(UIScrollViewIndicatorStyle)style
{
	_indicatorStyle = style;
	[self setNeedsDisplay];
}

- (CGFloat)knobSize
{
	const CGRect bounds = self.bounds;
	const CGFloat dimension = MAX(bounds.size.width, bounds.size.height);
	const CGFloat knobScale = MIN(1, (dimension / _contentSize));
	return MAX((dimension * knobScale), 50);
}

- (CGRect)knobRect
{
	const CGRect bounds = self.bounds;
	const CGFloat dimension = MAX(bounds.size.width, bounds.size.height);
	const CGFloat maxContentSize = MAX(1,(_contentSize-dimension));
	const CGFloat knobSize = [self knobSize];
	const CGFloat positionScale = MIN(1, (MIN(_contentOffset,maxContentSize) / maxContentSize));
	const CGFloat knobPosition = (dimension - knobSize) * positionScale;
	
	if (_isVertical) {
		return CGRectMake(bounds.origin.x, knobPosition, bounds.size.width, knobSize);
	} else {
		return CGRectMake(knobPosition, bounds.origin.y, knobSize, bounds.size.height);
	}
}

- (void)setContentOffset:(CGFloat)newOffset
{
	_contentOffset = MIN(MAX(0,newOffset),_contentSize);
	[self setNeedsDisplay];
}

- (void)setContentSize:(CGFloat)newContentSize
{
	_contentSize = newContentSize;
	[self setNeedsDisplay];
}

- (void)setContentOffsetWithLastTouch
{
	const CGRect bounds = self.bounds;
	const CGFloat dimension = _isVertical? bounds.size.height : bounds.size.width;
	const CGFloat maxContentOffset = _contentSize - dimension;
	const CGFloat knobSize = [self knobSize];
	const CGFloat point = _isVertical? _lastTouchLocation.y : _lastTouchLocation.x;
	const CGFloat knobPosition = MIN(MAX(0, point-_dragOffset), (dimension-knobSize));
	const CGFloat contentOffset = (knobPosition / (dimension-knobSize)) * maxContentOffset;

	[self setContentOffset:contentOffset];
}

- (void)pageUp
{
	if (_isVertical) {
		[self setContentOffset:_contentOffset-self.bounds.size.height];
	} else {
		[self setContentOffset:_contentOffset-self.bounds.size.width];
	}
}

- (void)pageDown
{
	if (_isVertical) {
		[self setContentOffset:_contentOffset+self.bounds.size.height];
	} else {
		[self setContentOffset:_contentOffset+self.bounds.size.width];
	}
}

- (void)autoPageContent
{
	const CGRect knobRect = [self knobRect];

	if (!CGRectContainsPoint(knobRect, _lastTouchLocation) && CGRectContainsPoint(self.bounds, _lastTouchLocation)) {
		BOOL shouldPageUp;

		if (_isVertical) {
			shouldPageUp = (_lastTouchLocation.y < knobRect.origin.y);
		} else {
			shouldPageUp = (_lastTouchLocation.x < knobRect.origin.x);
		}
		
		if (shouldPageUp) {
			[self pageUp];
		} else {
			[self pageDown];
		}

		[_delegate _UIScroller:self contentOffsetDidChange:_contentOffset];
	}
}

- (void)startHoldPaging
{
	[_holdTimer invalidate];
	_holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(autoPageContent) userInfo:nil repeats:YES];
}

- (void)drawRect:(CGRect)rect
{
	CGRect knobRect = [self knobRect];

	if (_isVertical) {
		knobRect = CGRectInset(knobRect, 1, 8);
	} else {
		knobRect = CGRectInset(knobRect, 8, 1);
	}

	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:knobRect cornerRadius:4];

	if (_indicatorStyle == UIScrollViewIndicatorStyleBlack) {
		[[[UIColor blackColor] colorWithAlphaComponent:0.5] setFill];
	} else if (_indicatorStyle == UIScrollViewIndicatorStyleWhite) {
		[[[UIColor whiteColor] colorWithAlphaComponent:0.5] setFill];
	} else {
		[[[UIColor blackColor] colorWithAlphaComponent:0.5] setFill];
		[[[UIColor whiteColor] colorWithAlphaComponent:0.2] setStroke];
		[path setLineWidth:1.5];
		[path stroke];
	}
	
	[path fill];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	_lastTouchLocation = [[touches anyObject] locationInView:self];
	const CGRect knobRect = [self knobRect];

	if (CGRectContainsPoint(knobRect,_lastTouchLocation)) {
		if (_isVertical) {
			_dragOffset = _lastTouchLocation.y - knobRect.origin.y;
		} else {
			_dragOffset = _lastTouchLocation.x - knobRect.origin.x;
		}
		_draggingKnob = YES;
	} else {
		if (_UIScrollerJumpToSpotThatIsClicked) {
			_dragOffset = [self knobSize] / 2.f;
			_draggingKnob = YES;
			[self setContentOffsetWithLastTouch];
			[_delegate _UIScroller:self contentOffsetDidChange:_contentOffset];
		} else {
			[self autoPageContent];
			_holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(startHoldPaging) userInfo:nil repeats:NO];
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	_lastTouchLocation = [[touches anyObject] locationInView:self];

	if (_draggingKnob) {
		[self setContentOffsetWithLastTouch];
		[_delegate _UIScroller:self contentOffsetDidChange:_contentOffset];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_draggingKnob) {
		_draggingKnob = NO;
		[_delegate _UIScrollerDidEndDragging:self withEvent:event];
	} else {
		[_holdTimer invalidate];
		_holdTimer = nil;
	}
}

@end
