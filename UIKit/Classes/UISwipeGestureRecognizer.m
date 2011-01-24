//  Created by Sean Heber on 1/24/11.
#import "UISwipeGestureRecognizer.h"
#import "UIGestureRecognizerSubclass.h"

@implementation UISwipeGestureRecognizer
@synthesize direction=_direction, numberOfTouchesRequired=_numberOfTouchesRequired;

- (id)initWithTarget:(id)target action:(SEL)action
{
	if ((self=[super initWithTarget:target action:action])) {
		_direction = UISwipeGestureRecognizerDirectionRight;
		_numberOfTouchesRequired = 1;
	}
	return self;
}

@end
