//  Created by Sean Heber on 5/28/10.
#import "UIView.h"

typedef enum {
	UIScrollViewIndicatorStyleDefault,
	UIScrollViewIndicatorStyleBlack,
	UIScrollViewIndicatorStyleWhite
} UIScrollViewIndicatorStyle;

@class UIScroller, UIImageView, UIScrollView;

@protocol UIScrollViewDelegate <NSObject>
@optional
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end

@interface UIScrollView : UIView {
@package
	id _delegate;
@private
	CGPoint _contentOffset;
	CGSize _contentSize;
	UIEdgeInsets _contentInset;
	UIEdgeInsets _scrollIndicatorInsets;
	UIScroller *_verticalScroller;
	UIScroller *_horizontalScroller;
	BOOL _scrollEnabled;
	BOOL _showsVerticalScrollIndicator;
	BOOL _showsHorizontalScrollIndicator;
	float _maximumZoomScale;
	float _minimumZoomScale;
	float _zoomScale;
	BOOL _scrollsToTop;
	UIScrollViewIndicatorStyle _indicatorStyle;
	BOOL _delaysContentTouches;
	BOOL _pagingEnabled;
	NSTimer *_dragDelegateTimer;
	
	struct {
		BOOL scrollViewDidScroll : 1;
		BOOL scrollViewWillBeginDragging : 1;
		BOOL scrollViewDidEndDragging : 1;
	} _delegateCan;	
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated;

- (void)setContentOffset:(CGPoint)theOffset animated:(BOOL)animated;
- (void)flashScrollIndicators;		// does nothing

@property (nonatomic) CGSize contentSize;
@property (nonatomic) CGPoint contentOffset;
@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic) UIEdgeInsets scrollIndicatorInsets;
@property (nonatomic) UIScrollViewIndicatorStyle indicatorStyle;
@property (nonatomic) BOOL showsHorizontalScrollIndicator;
@property (nonatomic) BOOL showsVerticalScrollIndicator;
@property (nonatomic, getter=isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic, assign) id<UIScrollViewDelegate> delegate;
@property (nonatomic) BOOL scrollsToTop;
@property (nonatomic) BOOL delaysContentTouches;	// no effect
@property (nonatomic, readonly, getter=isDragging) BOOL dragging;
@property (nonatomic, readonly, getter=isDecelerating) BOOL decelerating;	// always returns NO
@property (nonatomic, assign) BOOL pagingEnabled;	// not implemented

- (void)setZoomScale:(float)scale animated:(BOOL)animated;
@property (nonatomic) float maximumZoomScale;
@property (nonatomic) float minimumZoomScale;
@property (nonatomic) float zoomScale;

@end
