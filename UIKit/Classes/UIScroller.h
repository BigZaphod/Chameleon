//  Created by Sean Heber on 5/28/10.
#import "UIView.h"

@class UIImageView, UIScroller;

typedef enum {
	_UIScrollerOrientationVertical,
	_UIScrollerOrientationHorizontal
} _UIScrollerOrientation;

@protocol _UIScrollerDelegate
- (void)_UIScroller:(UIScroller *)scroller contentOffsetDidChange:(CGFloat)newOffset;
@end

@interface UIScroller : UIView {
@private
	id _delegate;
	_UIScrollerOrientation _orientation;
	UIImageView *_track;
	UIImageView *_knob;
	CGFloat _contentOffset;
	CGFloat _contentSize;
	CGFloat _dragOffset;
	BOOL _draggingKnob;
	CGPoint _lastTouchLocation;
	NSTimer *_holdTimer;
}

- (id)initWithOrientation:(_UIScrollerOrientation)theOrientation;

@property (nonatomic, assign) id<_UIScrollerDelegate> delegate;
@property (nonatomic, assign) CGFloat contentSize;		// used to calulate how big the slider knob should be (uses its own frame height/width and compares against this value)
@property (nonatomic, assign) CGFloat contentOffset;	// set this after contentSize is set or else it'll normalize in unexpected ways

@end
