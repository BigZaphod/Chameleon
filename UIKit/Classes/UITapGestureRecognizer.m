//  Created by Sean Heber on 6/29/10.
#import "UITapGestureRecognizer.h"

@implementation UITapGestureRecognizer
@synthesize numberOfTapsRequired=_numberOfTapsRequired, numberOfTouchesRequired=_numberOfTouchesRequired;

- (id)initWithTarget:(id)target action:(SEL)action
{
	if ((self=[super initWithTarget:target action:action])) {
		_numberOfTapsRequired = 1;
		_numberOfTouchesRequired = 1;
	}
	return self;
}

@end
