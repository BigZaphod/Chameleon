//  Created by Sean Heber on 6/25/10.
#import "UINavigationController.h"
#import "UITabBarController.h"
#import "UINavigationBar.h"
#import "UIKit+Private.h"

static const CGFloat NavigationBarHeight = 32;
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
		[rootViewController _setNavigationController:self];
		[_viewControllers addObject:rootViewController];
		[_navigationBar pushNavigationItem:rootViewController.navigationItem animated:NO];
	}
	return self;
}

- (void)dealloc
{
	[_viewControllers release];
	[_navigationBar release];
	[super dealloc];
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
	
	_navigationBar.frame = CGRectMake(0,0,320,NavigationBarHeight);
	[self.view addSubview:_navigationBar];
	
	UIViewController *topViewController = self.topViewController;
	topViewController.view.frame = [self _controllerFrame];
	[self.view addSubview:topViewController.view];
}

- (void)setViewControllers:(NSArray *)newViewControllers animated:(BOOL)animated
{
	NSAssert(([newViewControllers count] >= 1), nil);
	if (newViewControllers != _viewControllers) {
		
		UIViewController *previousTopController = self.topViewController;
		[previousTopController viewWillDisappear:animated];
		[previousTopController.view removeFromSuperview];
		[previousTopController viewDidDisappear:animated];
		
		[_viewControllers release];
		_viewControllers = [newViewControllers mutableCopy];
		
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:[_viewControllers count]];
		
		for (UIViewController *controller in _viewControllers) {
			[controller _setNavigationController:self];
			[items addObject:controller.navigationItem];
		}
		
		[_navigationBar setItems:items animated:animated];
		
		UIViewController *newTopController = self.topViewController;
		[newTopController viewWillAppear:animated];
		newTopController.view.frame = [self _controllerFrame];
		[self.view addSubview:newTopController.view];
		[newTopController viewDidAppear:animated];
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
	NSAssert(![viewController isKindOfClass:[UITabBarController class]], nil);
	NSAssert(![_viewControllers containsObject:viewController], nil);
	
	UIViewController *previousViewController = self.topViewController;

	[viewController _setNavigationController:self];
	[_viewControllers addObject:viewController];

	[previousViewController viewWillDisappear:animated];
	[viewController viewWillAppear:animated];

	[_navigationBar pushNavigationItem:viewController.navigationItem animated:animated];
	[previousViewController.view removeFromSuperview];
	viewController.view.frame = [self _controllerFrame];
	[self.view addSubview:viewController.view];
	
	[previousViewController viewDidDisappear:animated];
	[viewController viewDidAppear:animated];
}

- (UIViewController *)_popViewControllerWithoutPoppingNavigationBarAnimated:(BOOL)animate
{
	if ([_viewControllers count] > 1) {
		UIViewController *oldViewController = [self.topViewController retain];
		
		[_viewControllers removeLastObject];
		[oldViewController _setNavigationController:nil];

		UIViewController *nextViewController = self.topViewController;
		
		[oldViewController viewWillDisappear:animate];
		[nextViewController viewWillAppear:animate];
		
		[oldViewController.view removeFromSuperview];
		nextViewController.view.frame = [self _controllerFrame];
		[self.view addSubview:nextViewController.view];
		
		[oldViewController viewDidDisappear:animate];
		[nextViewController viewDidAppear:animate];
		
		return [oldViewController autorelease];
	} else {
		return nil;
	}
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

@end
