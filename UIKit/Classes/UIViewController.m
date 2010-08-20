//  Created by Sean Heber on 6/25/10.
#import "UIViewController.h"
#import "UIView+UIPrivate.h"
#import "UIScreen.h"
#import "UIWindow.h"
#import "UINavigationItem.h"
#import "UIBarButtonItem.h"
#import "UINavigationController.h"
#import "UISplitViewController.h"

@implementation UIViewController
@synthesize view=_view, wantsFullScreenLayout=_wantsFullScreenLayout, title=_title, contentSizeForViewInPopover=_contentSizeForViewInPopover;
@synthesize modalInPopover=_modalInPopover, toolbarItems=_toolbarItems, modalPresentationStyle=_modalPresentationStyle, editing=_editing;
@synthesize modalViewController=_modalViewController, parentViewController=_parentViewController;
@synthesize modalTransitionStyle=_modalTransitionStyle;

- (id)init
{
	return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	if ((self=[super init])) {
		_contentSizeForViewInPopover = CGSizeMake(320,1100);
	}
	return self;
}

- (void)dealloc
{
	[_modalViewController release];
	[_navigationItem release];
	[_title release];
	[_view release];
	[super dealloc];
}

- (NSString *)nibName
{
	return nil;
}

- (NSBundle *)nibBundle
{
	return nil;
}

- (UIResponder *)nextResponder
{
	return _view.superview;
}

- (BOOL)isViewLoaded
{
	return (_view != nil);
}

- (UIView *)view
{
	if ([self isViewLoaded]) {
		return _view;
	} else {
		[self loadView];
		[_view _setViewController:self];
		[self viewDidLoad];
		return _view;
	}
}

- (void)loadView
{
	_view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
}

- (void)viewDidLoad
{
}

- (void)viewDidUnload
{
}

- (void)didReceiveMemoryWarning
{
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)viewDidDisappear:(BOOL)animated
{
}

- (UIInterfaceOrientation)interfaceOrientation
{
	return UIDeviceOrientationPortrait;
}

- (UINavigationItem *)navigationItem
{
	if (!_navigationItem) {
		_navigationItem = [[UINavigationItem alloc] initWithTitle:self.title];
	}
	return _navigationItem;
}

- (void)_setParentViewController:(UIViewController *)parentController
{
	_parentViewController = parentController;
}

- (void)setToolbarItems:(NSArray *)theToolbarItems animated:(BOOL)animated
{
	if (_toolbarItems != theToolbarItems) {
		[_toolbarItems release];
		_toolbarItems = [theToolbarItems retain];
	}
}

- (void)setToolbarItems:(NSArray *)theToolbarItems
{
	[self setToolbarItems:theToolbarItems animated:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	_editing = editing;
}

- (void)setEditing:(BOOL)editing
{
	[self setEditing:editing animated:NO];
}

- (UIBarButtonItem *)editButtonItem
{
	// this should really return a fancy bar button item that toggles between edit/done and sends setEditing:animated: messages to this controller
	return nil;
}

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
	if (!_modalViewController && _modalViewController != self) {
		_modalViewController = [modalViewController retain];
		[_modalViewController _setParentViewController:self];

		[_modalViewController viewWillAppear:animated];
		[self viewWillDisappear:animated];


		UIWindow *window = self.view.window;
		UIView *selfView = self.view;
		UIView *newView = _modalViewController.view;
		
		newView.autoresizingMask = selfView.autoresizingMask;
		newView.frame = _wantsFullScreenLayout? window.screen.bounds : window.screen.applicationFrame;
		[window addSubview:newView];
		selfView.hidden = YES;		// I think the real one may actually remove it, which would mean needing to remember the superview, I guess? Not sure...
		
		[_modalViewController viewDidAppear:animated];
		[self viewDidDisappear:animated];
	}
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
	// NOTE: This is not implemented entirely correctly - the actual dismissModalViewController is somewhat subtle.
	// There is supposed to be a stack of modal view controllers that dismiss in a specific way,e tc.
	// The whole system of related view controllers is not really right - not just with modals, but everything else like
	// navigationController, too, which is supposed to return the nearest nav controller down the chain and it doesn't right now.

	if (_modalViewController) {
		
		// if the modalViewController being dismissed has a modalViewController of its own, then we need to go dismiss that, too.
		// otherwise things can be left hanging around.
		if (_modalViewController.modalViewController) {
			[_modalViewController dismissModalViewControllerAnimated:animated];
		}
		
		[self viewWillAppear:animated];
		
		[_modalViewController _setParentViewController:nil];
		[_modalViewController autorelease];
		_modalViewController = nil;
		[_modalViewController.view removeFromSuperview];
		self.view.hidden = NO;

		[self viewDidAppear:animated];
	} else {
		[self.parentViewController dismissModalViewControllerAnimated:animated];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (id)_nearestParentViewControllerThatIsKindOf:(Class)c
{
	UIViewController *controller = _parentViewController;

	while (controller && ![controller isKindOfClass:c]) {
		controller = [controller parentViewController];
	}

	return controller;
}

- (UINavigationController *)navigationController
{
	return [self _nearestParentViewControllerThatIsKindOf:[UINavigationController class]];
}

- (UISplitViewController *)splitViewController
{
	return [self _nearestParentViewControllerThatIsKindOf:[UISplitViewController class]];
}

@end
