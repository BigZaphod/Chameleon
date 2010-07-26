//  Created by Sean Heber on 6/22/10.
#import "UIView.h"

@interface _UIViewAnimationGroup : NSObject {
@private
	NSString *_name;
	void *_context;
	NSUInteger _waitingAnimations;
	BOOL _didSendStartMessage;
	NSTimeInterval _animationDelay;
	NSTimeInterval _animationDuration;
	UIViewAnimationCurve _animationCurve;
	id _animationDelegate;
	SEL _animationDidStopSelector;
	SEL _animationWillStartSelector;
	BOOL _animationBeginsFromCurrentState;
	BOOL _animationRepeatAutoreverses;
	float _animationRepeatCount;
	CFTimeInterval _animationBeginTime;
	CALayer *_transitionLayer;
	UIViewAnimationTransition _transitionType;
	BOOL _transitionShouldCache;
}

+ (id)animationGroupWithName:(NSString *)theName context:(void *)theContext;

- (id)actionForLayer:(CALayer *)layer forKey:(NSString *)keyPath;

- (void)setAnimationBeginsFromCurrentState:(BOOL)beginFromCurrentState;
- (void)setAnimationCurve:(UIViewAnimationCurve)curve;
- (void)setAnimationDelay:(NSTimeInterval)delay;
- (void)setAnimationDelegate:(id)delegate;			// retained! (also true of the real UIKit)
- (void)setAnimationDidStopSelector:(SEL)selector;
- (void)setAnimationDuration:(NSTimeInterval)duration;
- (void)setAnimationRepeatAutoreverses:(BOOL)repeatAutoreverses;
- (void)setAnimationRepeatCount:(float)repeatCount;
- (void)setAnimationTransition:(UIViewAnimationTransition)transition forView:(UIView *)view cache:(BOOL)cache;
- (void)setAnimationWillStartSelector:(SEL)selector;

- (void)commit;

@end
