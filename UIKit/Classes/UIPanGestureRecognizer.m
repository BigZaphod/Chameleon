//  Created by Sean Heber on 1/24/11.
#import "UIPanGestureRecognizer.h"

@implementation UIPanGestureRecognizer
@synthesize maximumNumberOfTouches=_maximumNumberOfTouches, minimumNumberOfTouches=_minimumNumberOfTouches;

- (id)initWithTarget:(id)target action:(SEL)action
{
	if ((self=[super initWithTarget:target action:action])) {
		_minimumNumberOfTouches = 1;
		_maximumNumberOfTouches = NSUIntegerMax;
	}
	return self;
}

- (CGPoint)translationInView:(UIView *)view
{
	return CGPointZero;
}

- (void)setTranslation:(CGPoint)translation inView:(UIView *)view
{
}

- (CGPoint)velocityInView:(UIView *)view
{
	return CGPointZero;
}

@end
