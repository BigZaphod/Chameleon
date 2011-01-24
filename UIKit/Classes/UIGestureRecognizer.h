//  Created by Sean Heber on 6/29/10.
#import <Foundation/Foundation.h>

typedef enum {
	UIGestureRecognizerStatePossible,
	UIGestureRecognizerStateBegan,
	UIGestureRecognizerStateChanged,
	UIGestureRecognizerStateEnded,
	UIGestureRecognizerStateCancelled,
	UIGestureRecognizerStateFailed,
	UIGestureRecognizerStateRecognized = UIGestureRecognizerStateEnded
} UIGestureRecognizerState;

@class UIView, UIGestureRecognizer, UITouch, UIEvent;

@protocol UIGestureRecognizerDelegate <NSObject>
@optional
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
@end

@interface UIGestureRecognizer : NSObject {
@private
	id _delegate;
	BOOL _delaysTouchesBegan;
	BOOL _delaysTouchesEnded;
	BOOL _cancelsTouchesInView;
	BOOL _enabled;
	UIGestureRecognizerState _state;
	__weak UIView *view;
	
	struct {
		BOOL shouldBegin : 1;
		BOOL shouldReceiveTouch : 1;
		BOOL shouldRecognizeSimultaneouslyWithGestureRecognizer : 1;
	} _delegateHas;	
}

- (id)initWithTarget:(id)target action:(SEL)action;

- (void)addTarget:(id)target action:(SEL)action;
- (void)removeTarget:(id)target action:(SEL)action;

- (void)requireGestureRecognizerToFail:(UIGestureRecognizer *)otherGestureRecognizer;
- (CGPoint)locationInView:(UIView *)view;

@property (nonatomic, assign) id<UIGestureRecognizerDelegate> delegate;
@property (nonatomic) BOOL delaysTouchesBegan;
@property (nonatomic) BOOL delaysTouchesEnded;
@property (nonatomic) BOOL cancelsTouchesInView;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, readonly) UIGestureRecognizerState state;
@property (nonatomic, readonly) UIView *view;

@end
