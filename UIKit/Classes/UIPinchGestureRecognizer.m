//  Created by Sean Heber on 1/24/11.
#import "UIPinchGestureRecognizer.h"

@implementation UIPinchGestureRecognizer
@synthesize scale=_scale;

- (id)initWithTarget:(id)target action:(SEL)action
{
	if ((self=[super initWithTarget:target action:action])) {
		_scale = 1;
	}
	return self;
}

- (CGFloat)velocity
{
	return 0;
}

@end
