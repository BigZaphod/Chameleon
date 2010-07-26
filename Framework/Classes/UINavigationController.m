//  Created by Sean Heber on 6/25/10.
#import "UINavigationController.h"

@implementation UINavigationController
@synthesize viewControllers=_viewControllers, delegate=_delegate;

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	if ((self=[super initWithNibName:nil bundle:nil])) {
	}
	return self;
}

- (void)dealloc
{
	[_viewControllers release];
	[super dealloc];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animate
{
	return nil;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	return nil;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
	return nil;
}

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
}

- (UINavigationBar *)navigationBar
{
	return nil;
}

- (UIToolbar *)toolbar
{
	return nil;
}

@end
