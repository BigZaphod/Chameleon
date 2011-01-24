//  Created by Sean Heber on 6/29/10.
#import "UITapGestureRecognizer.h"
#import "UIGestureRecognizerSubclass.h"

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

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
	// this logic is here based on a note in the docs for -canBePreventedByGestureRecognizer:
	// it may not be correct :)
	if ([preventingGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
		return (((UITapGestureRecognizer *)preventingGestureRecognizer).numberOfTapsRequired > self.numberOfTapsRequired);
	} else {
		return [super canBePreventedByGestureRecognizer:preventingGestureRecognizer];
	}
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
	// this logic is here based on a note in the docs for -canPreventGestureRecognizer:
	// it may not be correct :)
	if ([preventedGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
		return (((UITapGestureRecognizer *)preventedGestureRecognizer).numberOfTapsRequired <= self.numberOfTapsRequired);
	} else {
		return [super canPreventGestureRecognizer:preventedGestureRecognizer];
	}
}

@end
