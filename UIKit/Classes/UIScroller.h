//  Created by Sean Heber on 5/28/10.
#import "UIView.h"
#import "UIScrollView.h"

@class UIImageView, UIScroller;

@protocol _UIScrollerDelegate
- (void)_UIScroller:(UIScroller *)scroller contentOffsetDidChange:(CGFloat)newOffset;
@end

@interface UIScroller : UIView {
@private
	id _delegate;
	CGFloat _contentOffset;
	CGFloat _contentSize;
	CGFloat _dragOffset;
	BOOL _draggingKnob;
	BOOL _isVertical;
	CGPoint _lastTouchLocation;
	NSTimer *_holdTimer;
	UIScrollViewIndicatorStyle _indicatorStyle;
}

@property (nonatomic, assign) id<_UIScrollerDelegate> delegate;
@property (nonatomic, assign) CGFloat contentSize;		// used to calulate how big the slider knob should be (uses its own frame height/width and compares against this value)
@property (nonatomic, assign) CGFloat contentOffset;	// set this after contentSize is set or else it'll normalize in unexpected ways
@property (nonatomic, readonly, getter=isDragging) BOOL dragging;
@property (nonatomic) UIScrollViewIndicatorStyle indicatorStyle;

@end
