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
@synthesize state=_state;

- (id)initWithTarget:(id)target action:(SEL)action
{
	if ((self=[super init])) {
		_state = UIGestureRecognizerStatePossible;
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)requireGestureRecognizerToFail:(UIGestureRecognizer *)otherGestureRecognizer
{
}

- (CGPoint)locationInView:(UIView *)view
{
	return CGPointZero;
}

@end
