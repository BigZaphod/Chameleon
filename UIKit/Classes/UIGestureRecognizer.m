//
//  UIGestureRecognizer.m
//  UIKit for OSX
//
//  Created by Sean on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIGestureRecognizer.h"


@implementation UIGestureRecognizer
@synthesize delegate=_delegate, delaysTouchesBegan=_delaysTouchesBegan, delaysTouchesEnded=_delaysTouchesEnded, cancelsTouchesInView=_cancelsTouchesInView;
@synthesize state=_state, enabled=_enabled, view=_view;

- (id)initWithTarget:(id)target action:(SEL)action
{
	if ((self=[super init])) {
		_state = UIGestureRecognizerStatePossible;
		_cancelsTouchesInView = YES;
		_delaysTouchesBegan = NO;
		_delaysTouchesEnded = YES;
		_enabled = YES;

		[self addTarget:target action:action];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)_setView:(UIView *)v
{
	_view = v;
}

- (void)setDelegate:(id<UIGestureRecognizerDelegate>)aDelegate
{
	if (aDelegate != _delegate) {
		_delegate = aDelegate;
		_delegateHas.shouldBegin = [_delegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)];
		_delegateHas.shouldReceiveTouch = [_delegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)];
		_delegateHas.shouldRecognizeSimultaneouslyWithGestureRecognizer = [_delegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)];
	}
}

- (void)addTarget:(id)target action:(SEL)action
{
	NSAssert(target != nil, nil);
	NSAssert(action != NULL, nil);
}

- (void)removeTarget:(id)target action:(SEL)action
{
}

- (void)requireGestureRecognizerToFail:(UIGestureRecognizer *)otherGestureRecognizer
{
}

- (CGPoint)locationInView:(UIView *)view
{
	return CGPointZero;
}

@end
