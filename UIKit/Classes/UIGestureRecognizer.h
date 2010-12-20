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

@class UIView;

@protocol UIGestureRecognizerDelegate <NSObject>
@end

@interface UIGestureRecognizer : NSObject {
@private
	id _delegate;
	BOOL _delaysTouchesBegan;
	BOOL _delaysTouchesEnded;
	BOOL _cancelsTouchesInView;
	UIGestureRecognizerState _state;
}

- (id)initWithTarget:(id)target action:(SEL)action;

- (void)requireGestureRecognizerToFail:(UIGestureRecognizer *)otherGestureRecognizer;
- (CGPoint)locationInView:(UIView *)view;

@property (nonatomic, assign) id<UIGestureRecognizerDelegate> delegate;
@property (nonatomic) BOOL delaysTouchesBegan;
@property (nonatomic) BOOL delaysTouchesEnded;
@property (nonatomic) BOOL cancelsTouchesInView;
@property (nonatomic, readonly) UIGestureRecognizerState state;
@property (nonatomic, readonly) UIView *view;

@end
