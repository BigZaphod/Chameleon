//  Created by Sean Heber on 5/27/10.
#import "UIResponder.h"
#import "UIGeometry.h"

enum {
	UIViewAutoresizingNone                 = 0,
	UIViewAutoresizingFlexibleLeftMargin   = 1 << 0,
	UIViewAutoresizingFlexibleWidth        = 1 << 1,
	UIViewAutoresizingFlexibleRightMargin  = 1 << 2,
	UIViewAutoresizingFlexibleTopMargin    = 1 << 3,
	UIViewAutoresizingFlexibleHeight       = 1 << 4,
	UIViewAutoresizingFlexibleBottomMargin = 1 << 5
};
typedef NSUInteger UIViewAutoresizing;

typedef enum {
	UIViewContentModeScaleToFill,
	UIViewContentModeScaleAspectFit,
	UIViewContentModeScaleAspectFill,
	UIViewContentModeRedraw,
	UIViewContentModeCenter,
	UIViewContentModeTop,
	UIViewContentModeBottom,
	UIViewContentModeLeft,
	UIViewContentModeRight,
	UIViewContentModeTopLeft,
	UIViewContentModeTopRight,
	UIViewContentModeBottomLeft,
	UIViewContentModeBottomRight,
} UIViewContentMode;

typedef enum {
	UIViewAnimationCurveEaseInOut,
	UIViewAnimationCurveEaseIn,
	UIViewAnimationCurveEaseOut,
	UIViewAnimationCurveLinear
} UIViewAnimationCurve;

typedef enum {
	UIViewAnimationTransitionNone,
	UIViewAnimationTransitionFlipFromLeft,
	UIViewAnimationTransitionFlipFromRight,
	UIViewAnimationTransitionCurlUp,
	UIViewAnimationTransitionCurlDown,
} UIViewAnimationTransition;

@class UIColor, CALayer, UIViewController, UIGestureRecognizer;

@interface UIView : UIResponder {
@private
	__weak UIView *_superview;
	NSMutableSet *_subviews;
	BOOL _clearsContextBeforeDrawing;
	BOOL _autoresizesSubviews;
	BOOL _userInteractionEnabled;
	CALayer *_layer;
	NSInteger _tag;
	UIViewContentMode _contentMode;
	UIColor *_backgroundColor;
	BOOL _implementsDrawRect;
	BOOL _multipleTouchEnabled;
	BOOL _exclusiveTouch;
	__weak UIViewController *_viewController;
	UIViewAutoresizing _autoresizingMask;
}

+ (Class)layerClass;

- (id)initWithFrame:(CGRect)frame;
- (void)addSubview:(UIView *)subview;
- (void)insertSubview:(UIView *)subview atIndex:(NSInteger)index;
- (void)insertSubview:(UIView *)subview belowSubview:(UIView *)below;
- (void)removeFromSuperview;
- (void)bringSubviewToFront:(UIView *)subview;
- (void)sendSubviewToBack:(UIView *)subview;
- (CGRect)convertRect:(CGRect)toConvert fromView:(UIView *)fromView;
- (CGRect)convertRect:(CGRect)toConvert toView:(UIView *)toView;
- (CGPoint)convertPoint:(CGPoint)toConvert fromView:(UIView *)fromView;
- (CGPoint)convertPoint:(CGPoint)toConvert toView:(UIView *)toView;
- (void)setNeedsDisplay;
- (void)setNeedsDisplayInRect:(CGRect)invalidRect;
- (void)drawRect:(CGRect)rect;
- (void)sizeToFit;
- (CGSize)sizeThatFits:(CGSize)size;
- (void)setNeedsLayout;
- (void)layoutIfNeeded;
- (void)layoutSubviews;
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
- (UIView *)viewWithTag:(NSInteger)tag;
- (BOOL)isDescendantOfView:(UIView *)view;

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;	// no effect as of now

- (void)didAddSubview:(UIView *)subview;
- (void)didMoveToSuperview;
- (void)didMoveToWindow;
- (void)willMoveToSuperview:(UIView *)newSuperview;
- (void)willMoveToWindow:(UIWindow *)newWindow;
- (void)willRemoveSubview:(UIView *)subview;

+ (void)beginAnimations:(NSString *)animationID context:(void *)context;
+ (void)commitAnimations;
+ (void)setAnimationBeginsFromCurrentState:(BOOL)beginFromCurrentState;
+ (void)setAnimationCurve:(UIViewAnimationCurve)curve;
+ (void)setAnimationDelay:(NSTimeInterval)delay;
+ (void)setAnimationDelegate:(id)delegate;
+ (void)setAnimationDidStopSelector:(SEL)selector;
+ (void)setAnimationDuration:(NSTimeInterval)duration;
+ (void)setAnimationRepeatAutoreverses:(BOOL)repeatAutoreverses;
+ (void)setAnimationRepeatCount:(float)repeatCount;
+ (void)setAnimationTransition:(UIViewAnimationTransition)transition forView:(UIView *)view cache:(BOOL)cache;
+ (void)setAnimationWillStartSelector:(SEL)selector;
+ (BOOL)areAnimationsEnabled;
+ (void)setAnimationsEnabled:(BOOL)enabled;

@property (nonatomic) CGRect frame;
@property (nonatomic) CGRect bounds;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGAffineTransform transform;
@property (nonatomic, readonly) UIView *superview;
@property (nonatomic, readonly) UIWindow *window;
@property (nonatomic, readonly) NSArray *subviews;
@property (nonatomic) CGFloat alpha;
@property (nonatomic, getter=isOpaque) BOOL opaque;
@property (nonatomic) BOOL clearsContextBeforeDrawing;
@property (nonatomic, copy) UIColor *backgroundColor;
@property (nonatomic, readonly) CALayer *layer;
@property (nonatomic) BOOL clipsToBounds;
@property (nonatomic) BOOL autoresizesSubviews;
@property (nonatomic) UIViewAutoresizing autoresizingMask;
@property (nonatomic) CGRect contentStretch;
@property (nonatomic) NSInteger tag;
@property (nonatomic, getter=isHidden) BOOL hidden;
@property (nonatomic, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;
@property (nonatomic) UIViewContentMode contentMode;
@property (nonatomic, getter=isMultipleTouchEnabled) BOOL multipleTouchEnabled;	// state is maintained, but it has no effect
@property (nonatomic, getter=isExclusiveTouch) BOOL exclusiveTouch; // state is maintained, but it has no effect

@end
