//  Created by Sean Heber on 6/22/10.
#import "_UIViewAnimationGroup.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor.h"

static CAMediaTimingFunction *CAMediaTimingFunctionFromUIViewAnimationCurve(UIViewAnimationCurve curve)
{
	switch (curve) {
		case UIViewAnimationCurveEaseInOut:	return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		case UIViewAnimationCurveEaseIn:	return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
		case UIViewAnimationCurveEaseOut:	return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		case UIViewAnimationCurveLinear:	return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	}
	return nil;
}

@implementation _UIViewAnimationGroup

- (id)initWithGroupName:(NSString *)theName context:(void *)theContext
{
	if ((self=[super init])) {
		_name = [theName copy];
		_context = theContext;
		_waitingAnimations = 1;
		_animationDuration = 0.2;
		_animationCurve = UIViewAnimationCurveEaseInOut;
		_animationBeginsFromCurrentState = NO;
		_animationRepeatAutoreverses = NO;
		_animationRepeatCount = 0;
		_animationBeginTime = CACurrentMediaTime();
	}
	return self;
}

- (void)dealloc
{
	[_name release];
	[_animationDelegate release];
	[super dealloc];
}

+ (id)animationGroupWithName:(NSString *)theName context:(void *)theContext
{
	return [[[self alloc] initWithGroupName:theName context:theContext] autorelease];
}

- (void)notifyAnimationsDidStopIfNeededUsingStatus:(BOOL)animationsDidFinish
{
	if (_waitingAnimations == 0) {
		if ([_animationDelegate respondsToSelector:_animationDidStopSelector]) {
			NSMethodSignature *signature = [_animationDelegate methodSignatureForSelector:_animationDidStopSelector];
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:_animationDidStopSelector];
			NSInteger remaining = [signature numberOfArguments] - 2;
			
			NSNumber *finishedArgument = [NSNumber numberWithBool:animationsDidFinish];
			
			if (remaining > 0) {
				[invocation setArgument:&_name atIndex:2];
				remaining--;
			}

			if (remaining > 0) {
				[invocation setArgument:&finishedArgument atIndex:3];
				remaining--;
			}

			if (remaining > 0) {
				[invocation setArgument:&_context atIndex:4];
			}
			
			[invocation invokeWithTarget:_animationDelegate];
		}
	}
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
	if (!_didSendStartMessage) {
		if ([_animationDelegate respondsToSelector:_animationWillStartSelector]) {
			NSMethodSignature *signature = [_animationDelegate methodSignatureForSelector:_animationWillStartSelector];
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:_animationWillStartSelector];
			NSInteger remaining = [signature numberOfArguments] - 2;
			
			if (remaining > 0) {
				[invocation setArgument:&_name atIndex:2];
				remaining--;
			}
			
			if (remaining > 0) {
				[invocation setArgument:&_context atIndex:3];
			}
			
			[invocation invokeWithTarget:_animationDelegate];
		}
		_didSendStartMessage = YES;
	}
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	_waitingAnimations--;
	[self notifyAnimationsDidStopIfNeededUsingStatus:flag];
}

- (CAAnimation *)addAnimation:(CAAnimation *)animation
{
	animation.timingFunction = CAMediaTimingFunctionFromUIViewAnimationCurve(_animationCurve);
	animation.duration = _animationDuration;
	animation.beginTime = _animationBeginTime + _animationDelay;
	animation.repeatCount = _animationRepeatCount;
	animation.autoreverses = _animationRepeatAutoreverses;
	animation.fillMode = kCAFillModeBackwards;
	animation.delegate = self;
	animation.removedOnCompletion = YES;
	_waitingAnimations++;
	return animation;
}

- (id)actionForLayer:(CALayer *)layer forKey:(NSString *)keyPath
{
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
	animation.fromValue = _animationBeginsFromCurrentState? [layer.presentationLayer valueForKey:keyPath] : [layer valueForKey:keyPath];
	return [self addAnimation:animation];
}

- (void)setAnimationBeginsFromCurrentState:(BOOL)beginFromCurrentState
{
	_animationBeginsFromCurrentState = beginFromCurrentState;
}

- (void)setAnimationCurve:(UIViewAnimationCurve)curve
{
	_animationCurve = curve;
}

- (void)setAnimationDelay:(NSTimeInterval)delay
{
	_animationDelay = delay;
}

- (void)setAnimationDelegate:(id)delegate
{
	if (delegate != _animationDelegate) {
		[_animationDelegate release];
		_animationDelegate = [delegate retain];
	}
}

- (void)setAnimationDidStopSelector:(SEL)selector
{
	_animationDidStopSelector = selector;
}

- (void)setAnimationDuration:(NSTimeInterval)newDuration
{
	_animationDuration = newDuration;
}

- (void)setAnimationRepeatAutoreverses:(BOOL)repeatAutoreverses
{
	_animationRepeatAutoreverses = repeatAutoreverses;
}

- (void)setAnimationRepeatCount:(float)repeatCount
{
	_animationRepeatCount = repeatCount;
}

- (void)setAnimationTransition:(UIViewAnimationTransition)transition forView:(UIView *)view cache:(BOOL)cache
{
	_transitionLayer = view.layer;
	_transitionType = transition;
	_transitionShouldCache = cache;
}

- (void)setAnimationWillStartSelector:(SEL)selector
{
	_animationWillStartSelector = selector;
}

- (void)commit
{
	if (_transitionLayer) {
		CATransition *trans = [CATransition animation];
		trans.type = kCATransitionMoveIn;
		
		switch (_transitionType) {
			case UIViewAnimationTransitionCurlUp:			trans.subtype = kCATransitionFromTop;		break;
			case UIViewAnimationTransitionCurlDown:			trans.subtype = kCATransitionFromBottom;	break;
			case UIViewAnimationTransitionFlipFromLeft:		trans.subtype = kCATransitionFromLeft;		break;
			case UIViewAnimationTransitionFlipFromRight:	trans.subtype = kCATransitionFromRight;		break;
		}
		
		[_transitionLayer addAnimation:[self addAnimation:trans] forKey:kCATransition];
	}
	
	_waitingAnimations--;
	[self notifyAnimationsDidStopIfNeededUsingStatus:YES];
}

@end
