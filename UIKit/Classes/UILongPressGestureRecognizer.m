//  Created by Sean Heber on 6/29/10.
#import "UILongPressGestureRecognizer.h"

@implementation UILongPressGestureRecognizer
@synthesize minimumPressDuration=_minimumPressDuration, allowableMovement=_allowableMovement, numberOfTapsRequired=_numberOfTapsRequired;
@synthesize numberOfTouchesRequired=_numberOfTouchesRequired;

- (id)initWithTarget:(id)target action:(SEL)action
{
	if ((self=[super initWithTarget:target action:action])) {
		_allowableMovement = 10;
		_minimumPressDuration = 0.5;
		_numberOfTapsRequired = 0;
		_numberOfTouchesRequired = 1;
	}
	return self;
}

@end
