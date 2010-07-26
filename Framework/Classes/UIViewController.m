//  Created by Sean Heber on 6/25/10.
#import "UIViewController.h"
#import "UIView.h"
#import "UIKit+Private.h"
#import "UINavigationItem.h"
#import "UIBarButtonItem.h"

@implementation UIViewController
@synthesize view=_view, wantsFullScreenLayout=_wantsFullScreenLayout, title=_title, contentSizeForViewInPopover=_contentSizeForViewInPopover;
@synthesize modalInPopover=_modalInPopover, toolbarItems=_toolbarItems, modalPresentationStyle=_modalPresentationStyle, editing=_editing;

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

- (UINavigationController *)navigationController
{
	return nil;
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
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

@end
