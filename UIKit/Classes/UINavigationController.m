//  Created by Sean Heber on 6/25/10.
#import "UINavigationController.h"
#import "UIViewController+UIPrivate.h"
#import "UITabBarController.h"
#import "UINavigationBar.h"

static const NSTimeInterval kAnimationDuration = 0.33;
static const CGFloat NavigationBarHeight = 28;
//static const CGFloat ToolbarHeight = 32;

@implementation UINavigationController
@synthesize viewControllers=_viewControllers, delegate=_delegate, navigationBar=_navigationBar;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
	if ((self=[super initWithNibName:nibName bundle:bundle])) {
		_viewControllers = [[NSMutableArray alloc] initWithCapacity:1];
		_navigationBar = [UINavigationBar new];
		_navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_navigationBar.delegate = self;
	}
	return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	if ((self=[self initWithNibName:nil bundle:nil])) {
		self.viewControllers = [NSArray arrayWithObject:rootViewController];
	}
	return self;
}

- (void)dealloc
{
	[_viewControllers release];
	[_navigationBar release];
	[super dealloc];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)newDelegate
{
	_delegate = newDelegate;
	_delegateHas.didShowViewController = [_delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)];
	_delegateHas.willShowViewController = [_delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)];
}

- (CGRect)_controllerFrame
{
	CGRect controllerFrame = self.view.bounds;
	BOOL showingNavigationBar = YES;
	//BOOL showingToolbar = NO;

	if (showingNavigationBar) {
		controllerFrame.origin.y += NavigationBarHeight;
		controllerFrame.size.height -= NavigationBarHeight;
	}
	
	//if (showingToolbar) {
	//	controllerFrame.size.height -= ToolbarHeight;
	//}
	
	return controllerFrame;
}

- (void)loadView
{
	self.view = [[[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)] autorelease];
	self.view.clipsToBounds = YES;

	UIViewController *topViewController = self.topViewController;
	topViewController.view.frame = [self _controllerFrame];
	[self.view addSubview:topViewController.view];

	_navigationBar.frame = CGRectMake(0,0,320,NavigationBarHeight);
	[self.view addSubview:_navigationBar];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.topViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.topViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.topViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self.topViewController viewDidDisappear:animated];
}

- (void)setViewControllers:(NSArray *)newViewControllers animated:(BOOL)animated
{
	assert([newViewControllers count] >= 1);
	if (newViewControllers != _viewControllers) {
		UIViewController *previousTopController = self.topViewController;

		if (previousTopController) {
			[previousTopController.view removeFromSuperview];
		}

		for (UIViewController *controller in _viewControllers) {
			[controller _setParentViewController:nil];
		}
		
		[_viewControllers release];
		_viewControllers = [newViewControllers mutableCopy];
		
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:[_viewControllers count]];
		
		for (UIViewController *controller in _viewControllers) {
			[controller _setParentViewController:self];
			[items addObject:controller.navigationItem];
		}

		if ([self isViewLoaded]) {
			UIViewController *newTopController = self.topViewController;

			[newTopController viewWillAppear:animated];
			if (_delegateHas.willShowViewController) {
				[_delegate navigationController:self willShowViewController:newTopController animated:animated];
			}
			
			newTopController.view.frame = [self _controllerFrame];
			[self.view addSubview:newTopController.view];
			[self.view bringSubviewToFront:_navigationBar];

			[newTopController viewDidAppear:animated];
			if (_delegateHas.didShowViewController) {
				[_delegate navigationController:self didShowViewController:newTopController animated:animated];
			}
		}

		[_navigationBar setItems:items animated:animated];
	}
}

- (void)setViewControllers:(NSArray *)newViewControllers
{
	[self setViewControllers:newViewControllers animated:NO];
}

- (UIViewController *)topViewController
{
	return [_viewControllers lastObject];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	assert(![viewController isKindOfClass:[UITabBarController class]]);
	assert(![_viewControllers containsObject:viewController]);
	
	[viewController _setParentViewController:self];

	if ([self isViewLoaded]) {
		UIViewController *oldViewController = self.topViewController;

		const CGRect controllerFrame = [self _controllerFrame];
		const CGRect nextFrameStart = CGRectOffset(controllerFrame, controllerFrame.size.width, 0);
		const CGRect nextFrameEnd = controllerFrame;
		const CGRect oldFrameStart = controllerFrame;
		const CGRect oldFrameEnd = CGRectOffset(controllerFrame, -controllerFrame.size.width, 0);
		
		[self.view addSubview:viewController.view];

		[viewController viewWillAppear:animated];
		if (_delegateHas.willShowViewController) {
			[_delegate navigationController:self willShowViewController:viewController animated:animated];
		}
		
		if (animated) {
			viewController.view.frame = nextFrameStart;
			oldViewController.view.frame = oldFrameStart;
			
			[oldViewController retain];
			
			[UIView beginAnimations:@"PushViewController" context:(void *)oldViewController];
			[UIView setAnimationDuration:kAnimationDuration];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(_pushAnimationDidStop:finished:removeOldViewController:)];
			viewController.view.frame = nextFrameEnd;
			oldViewController.view.frame = oldFrameEnd;
			[UIView commitAnimations];
		} else {
			viewController.view.frame = nextFrameEnd;
			[oldViewController.view removeFromSuperview];
		}

		[viewController viewDidAppear:animated];
		if (_delegateHas.didShowViewController) {
			[_delegate navigationController:self didShowViewController:viewController animated:animated];
		}
	}

	[_viewControllers addObject:viewController];
	[_navigationBar pushNavigationItem:viewController.navigationItem animated:animated];
}

- (void)_pushAnimationDidStop:(NSString *)name finished:(NSNumber *)finished removeOldViewController:(UIViewController *)controller
{
	[controller.view removeFromSuperview];
	[controller release];
}

- (UIViewController *)_popViewControllerWithoutPoppingNavigationBarAnimated:(BOOL)animated
{
	if ([_viewControllers count] > 1) {
		UIViewController *oldViewController = [self.topViewController retain];

		[_viewControllers removeLastObject];
		[oldViewController _setParentViewController:nil];

		if ([self isViewLoaded]) {
			UIViewController *nextViewController = self.topViewController;

			const CGRect controllerFrame = [self _controllerFrame];
			const CGRect nextFrameStart = CGRectOffset(controllerFrame, -controllerFrame.size.width, 0);
			const CGRect nextFrameEnd = controllerFrame;
			const CGRect oldFrameStart = controllerFrame;
			const CGRect oldFrameEnd = CGRectOffset(controllerFrame, controllerFrame.size.width, 0);

			//nextViewController.view.frame = nextFrameEnd;

			[self.view addSubview:nextViewController.view];

			[nextViewController viewWillAppear:animated];
			if (_delegateHas.willShowViewController) {
				[_delegate navigationController:self willShowViewController:nextViewController animated:animated];
			}

			if (animated) {
				nextViewController.view.frame = nextFrameStart;
				oldViewController.view.frame = oldFrameStart;
				
				[oldViewController retain];

				[UIView beginAnimations:@"PopViewController" context:(void *)oldViewController];
				[UIView setAnimationDuration:kAnimationDuration];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(_popAnimationDidStop:finished:removeOldViewController:)];
				nextViewController.view.frame = nextFrameEnd;
				oldViewController.view.frame = oldFrameEnd;
				[UIView commitAnimations];
			} else {
				nextViewController.view.frame = nextFrameEnd;
				[oldViewController.view removeFromSuperview];
			}

			[nextViewController viewDidAppear:animated];
			if (_delegateHas.didShowViewController) {
				[_delegate navigationController:self didShowViewController:nextViewController animated:animated];
			}
		}
		
		return [oldViewController autorelease];
	} else {
		return nil;
	}
}

- (void)_popAnimationDidStop:(NSString *)name finished:(NSNumber *)finished removeOldViewController:(UIViewController *)controller
{
	[controller.view removeFromSuperview];
	[controller release];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animate
{
	UIViewController *controller = [self _popViewControllerWithoutPoppingNavigationBarAnimated:animate];
	if (controller) {
		[_navigationBar popNavigationItemAnimated:animate];
	}
	return controller;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	NSMutableArray *popped = [NSMutableArray new];

	while (self.topViewController != viewController) {
		UIViewController *poppedController = [self popViewControllerAnimated:animated];
		if (poppedController) {
			[popped addObject:poppedController];
		} else {
			break;
		}
	}
	
	return [popped autorelease];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
	return [self popToViewController:[_viewControllers objectAtIndex:0] animated:animated];
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
	[self _popViewControllerWithoutPoppingNavigationBarAnimated:YES];
	return YES;
}

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
}

- (UIToolbar *)toolbar
{
	return nil;
}

- (void)setContentSizeForViewInPopover:(CGSize)newSize
{
	self.topViewController.contentSizeForViewInPopover = newSize;
}

- (CGSize)contentSizeForViewInPopover
{
	return self.topViewController.contentSizeForViewInPopover;
}

@end
