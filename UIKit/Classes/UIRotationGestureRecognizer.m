//  Created by Sean Heber on 1/24/11.
#import "UIRotationGestureRecognizer.h"
#import "UIGestureRecognizerSubclass.h"

@implementation UIRotationGestureRecognizer
@synthesize rotation=_rotation;

- (id)initWithTarget:(id)target action:(SEL)action
{
	if ((self=[super initWithTarget:target action:action])) {
		_rotation = 0;
	}
	return self;
}

- (CGFloat)velocity
{
	return 0;
}

@end
