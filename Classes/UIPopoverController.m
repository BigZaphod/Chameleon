//  Created by Sean Heber on 6/25/10.
#import "UIPopoverController.h"

@implementation UIPopoverController
@synthesize delegate=_delegate, contentViewController=_contentViewController, popoverVisible=_popoverVisible;

- (id)initWithContentViewController:(UIViewController *)viewController
{
	if ((self=[super init])) {
		self.contentViewController = viewController;
	}
	return self;
}

- (void)dealloc
{
	[_contentViewController release];
	[super dealloc];
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
}

@end
