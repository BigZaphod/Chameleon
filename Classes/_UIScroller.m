//  Created by Sean Heber on 5/28/10.
#import "_UIScroller.h"
#import "UIImageView.h"
#import "UIImage.h"
#import "UITouch.h"
#import "UIKit+Private.h"

static const BOOL _UIScrollerJumpToSpotThatIsClicked = NO;

@implementation _UIScroller
@synthesize delegate=_delegate, contentOffset=_contentOffset, contentSize=_contentSize;

- (id)initWithOrientation:(_UIScrollerOrientation)theOrientation
{
	if ((self=[super init])) {
		_orientation = theOrientation;
		
		UIImage *knobImage, *trackImage;
		
		if (_orientation == _UIScrollerOrientationVertical) {
			trackImage = [[UIImage _frameworkImageNamed:@"<_UIScroller> vertical-track-dark.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:15];
			knobImage = [[UIImage _frameworkImageNamed:@"<_UIScroller> vertical-knob-dark.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:10];
		} else {
			trackImage = [[UIImage _frameworkImageNamed:@"<_UIScroller> horizontal-track-dark.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:7];
			knobImage = [[UIImage _frameworkImageNamed:@"<_UIScroller> horizontal-knob-dark.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:7];
		}

		[self addSubview:(_track = [[UIImageView alloc] initWithImage:trackImage])];
		[self addSubview:(_knob = [[UIImageView alloc] initWithImage:knobImage])];
	}
	return self;
}

- (void)dealloc
{
	[_track release];
	[_knob release];
	[super dealloc];
}

- (UIEdgeInsets)knobTrackInset
{
	if (_orientation == _UIScrollerOrientationVertical) {
		return UIEdgeInsetsMake(7,0,4,0);
	} else {
		return UIEdgeInsetsMake(0,7,0,4);
	}
}

- (CGFloat)knobContentSize
{
	return MAX(_contentSize, ((_orientation == _UIScrollerOrientationVertical)? self.bounds.size.height : self.bounds.size.width));
}

- (CGFloat)knobContentScale
{
	return ((_orientation == _UIScrollerOrientationVertical)? self.bounds.size.height : self.bounds.size.width) / self.knobContentSize;
}

- (CGFloat)maxKnobSize
{
	const UIEdgeInsets knobTrackInset = [self knobTrackInset];
	if (_orientation == _UIScrollerOrientationVertical) {
		return (self.bounds.size.height-knobTrackInset.top-knobTrackInset.bottom);
	} else {
		return (self.bounds.size.width-knobTrackInset.left-knobTrackInset.right);
	}
}

- (CGFloat)knobSize
{
	if (_orientation == _UIScrollerOrientationVertical) {
		return MAX(_knob.image.size.height,roundf(self.maxKnobSize*self.knobContentScale));
	} else {
		return MAX(_knob.image.size.width,roundf(self.maxKnobSize*self.knobContentScale));
	}
}

- (void)layoutSubviews
{
	_track.frame = self.bounds;

	if (self.knobContentScale < 1.f) {
		_knob.hidden = NO;
		const UIEdgeInsets knobTrackInset = [self knobTrackInset];
		const CGFloat modifiedContentSize = self.knobContentSize;
		CGFloat knobSize = self.knobSize;
		CGFloat modifiedContentOffset = MIN(MAX(0,_contentOffset),modifiedContentSize);	
		
		if (_orientation == _UIScrollerOrientationVertical) {
			CGFloat knobY = knobTrackInset.top + roundf(modifiedContentOffset*self.knobContentScale);
			_knob.frame = CGRectMake(0, MIN(knobY,self.bounds.size.height-knobTrackInset.bottom-knobSize), self.bounds.size.width, knobSize);
		} else {
			CGFloat knobX = knobTrackInset.left + roundf(modifiedContentOffset*self.knobContentScale);
			_knob.frame = CGRectMake(MIN(knobX,self.bounds.size.width-knobTrackInset.right-knobSize), 0, knobSize, self.bounds.size.height);
		}
	} else {
		_knob.hidden = YES;
	}
}

- (void)setContentOffset:(CGFloat)newOffset
{
	CGFloat minOffset;
	if (_orientation == _UIScrollerOrientationVertical) {
		minOffset = MAX(0,(_contentSize - self.bounds.size.height));
	} else {
		minOffset = MAX(0,(_contentSize - self.bounds.size.width));
	}
	_contentOffset = MAX(0,MIN(newOffset, minOffset));
	[self setNeedsLayout];
}

- (void)setContentSize:(CGFloat)newContentSize
{
	_contentSize = newContentSize;
	[self setNeedsLayout];
}

- (void)setContentOffsetWithPoint:(CGPoint)point
{
	CGFloat percentage;
	if (_orientation == _UIScrollerOrientationVertical) {
		percentage = MIN(1,MAX(0,((point.y-_dragOffset)/self.bounds.size.height)));
	} else {
		percentage = MIN(1,MAX(0,((point.x-_dragOffset)/self.bounds.size.width)));
	}
	[self setContentOffset:percentage * _contentSize];
}

- (void)pageUp
{
	if (_orientation == _UIScrollerOrientationVertical) {
		[self setContentOffset:_contentOffset-self.bounds.size.height];
	} else {
		[self setContentOffset:_contentOffset-self.bounds.size.width];
	}
}

- (void)pageDown
{
	if (_orientation == _UIScrollerOrientationVertical) {
		[self setContentOffset:_contentOffset+self.bounds.size.height];
	} else {
		[self setContentOffset:_contentOffset+self.bounds.size.width];
	}
}

- (void)autoPageContent
{
	if (!CGRectContainsPoint(_knob.frame,_lastTouchLocation) && CGRectContainsPoint(self.bounds,_lastTouchLocation)) {
		BOOL shouldPageUp;

		if (_orientation == _UIScrollerOrientationVertical) {
			shouldPageUp = (_lastTouchLocation.y < _knob.frame.origin.y);
		} else {
			shouldPageUp = (_lastTouchLocation.x < _knob.frame.origin.x);
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point = [[touches anyObject] locationInView:self];
	UIEdgeInsets knobTrackInset = self.knobTrackInset;

	if (CGRectContainsPoint(_knob.frame,point)) {
		if (_orientation == _UIScrollerOrientationVertical) {
			_dragOffset = point.y - _knob.frame.origin.y + knobTrackInset.top;
		} else {
			_dragOffset = point.x - _knob.frame.origin.x + knobTrackInset.left;
		}
		_draggingKnob = YES;
	} else {
		if (_UIScrollerJumpToSpotThatIsClicked) {
			if (_orientation == _UIScrollerOrientationVertical) {
				_dragOffset = (self.knobSize/2.f) + knobTrackInset.top;
			} else {
				_dragOffset = (self.knobSize/2.f) + knobTrackInset.left;
			}
			_draggingKnob = YES;
			[self setContentOffsetWithPoint:point];
			[_delegate _UIScroller:self contentOffsetDidChange:_contentOffset];
		} else {
			_lastTouchLocation = point;
			[self autoPageContent];
			_holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(startHoldPaging) userInfo:nil repeats:NO];
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_draggingKnob) {
		[self setContentOffsetWithPoint:[[touches anyObject] locationInView:self]];
		[_delegate _UIScroller:self contentOffsetDidChange:_contentOffset];
	} else {
		_lastTouchLocation = [[touches anyObject] locationInView:self];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_draggingKnob) {
		_draggingKnob = NO;
	} else {
		[_holdTimer invalidate];
		_holdTimer = nil;
	}
}

/*
- (void)_scrollWheelMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
	if (orientation == _UIScrollerOrientationVertical) {
		[self setContentOffset:contentOffset-delta.y];
	} else {
		[self setContentOffset:contentOffset-delta.x];
	}

	[delegate _UIScroller:self contentOffsetDidChange:contentOffset];
}
*/

@end
