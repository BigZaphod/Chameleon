//  Created by Sean Heber on 6/25/10.
#import "UIPopoverController+UIPrivate.h"
#import "UIPopoverWindow.h"
#import "UIPopoverWindowController.h"
#import "UIViewController.h"
#import "UIWindow.h"
#import "UIScreen+UIPrivate.h"
#import "UIKitView.h"
#import "UITouch.h"

@implementation UIPopoverController
@synthesize delegate=_delegate, contentViewController=_contentViewController, popoverVisible=_popoverVisible, passthroughViews=_passthroughViews;

- (id)init
{
	if ((self=[super init])) {
		NSRect defaultFrame = NSMakeRect(0, 0, 320.0f, 480.0f);
		
		_UIKitView = [[UIKitView alloc] initWithFrame:defaultFrame];
		[[_UIKitView UIScreen] _setPopoverController:self];
		
		UIPopoverWindow *popoverWindow = [[[UIPopoverWindow alloc] initWithContentRect:defaultFrame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES] autorelease];
		_popoverWindowController = [[UIPopoverWindowController alloc] initWithPopoverWindow:popoverWindow controller:self];

		[popoverWindow setDelegate:_popoverWindowController];
		[popoverWindow setContentView:_UIKitView];
		[popoverWindow setLevel:NSFloatingWindowLevel];
		[popoverWindow setHidesOnDeactivate:YES];
	}
	return self;
}

- (id)initWithContentViewController:(UIViewController *)viewController
{
	if ((self=[self init])) {
		self.contentViewController = viewController;
	}
	return self;
}

- (void)dealloc
{
	_delegate = nil;
	[_UIKitView release];
	[_passthroughViews release];
	[_popoverWindowController release];
	[_contentViewController release];
	[super dealloc];
}

- (void)setDelegate:(id<UIPopoverControllerDelegate>)newDelegate
{
	_delegate = newDelegate;
	_delegateHas.popoverControllerDidDismissPopover = [_delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)];
	_delegateHas.popoverControllerShouldDismissPopover = [_delegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)];
}

- (void)setContentViewController:(UIViewController *)viewController
{
	if (viewController != _contentViewController) {
		[_contentViewController.view removeFromSuperview];
		[_contentViewController release];
		_contentViewController = [viewController retain];
		[(UIWindow *)[_UIKitView UIWindow] addSubview:viewController.view];
	}
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
	// convert the rect into OSX screen coords
	CGRect windowRect = [view convertRect:rect toView:nil];
	CGRect screenRect = [view.window convertRect:windowRect toWindow:nil];
	CGRect desktopScreenRect = [view.window.screen convertRect:screenRect toScreen:nil];

	// the real popover points to the edge of the given rectangle.
	// since we're just using a point (for not) I'll just point to the center of it.
	// not ideal, sure, but works.
	CGPoint centerPoint = CGPointMake(CGRectGetMidX(desktopScreenRect), CGRectGetMidY(desktopScreenRect));
	NSPoint desktopWindowPoint = [[_UIKitView window] convertScreenToBase:NSPointFromCGPoint(centerPoint)];

	[(UIPopoverWindow *)[_popoverWindowController window] setFrameForContentSize:NSMakeSize(320.0f, 480.0f) atPoint:desktopWindowPoint inWindow:[_UIKitView window]];

	_contentViewController.view.frame = [_UIKitView UIWindow].bounds;
	
	_manuallyDismissed = NO;
	[_popoverWindowController showWindow:self];
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
	_manuallyDismissed = YES;
	[_popoverWindowController close];
}

- (void)_setWindowTitle:(NSString *)title
{
	[[_popoverWindowController window] setTitle:title];
}

- (void)_popoverWindowControllerDidClosePopoverWindow:(id)controller
{
	if (!_manuallyDismissed && _delegateHas.popoverControllerDidDismissPopover) {
		[_delegate popoverControllerDidDismissPopover:self];
	}
}

- (BOOL)_popoverWindowControllerShouldClosePopoverWindow:(id)controller
{
	if (_delegateHas.popoverControllerShouldDismissPopover) {
		return [_delegate popoverControllerShouldDismissPopover:self];
	} else {
		return YES;
	}
}

- (BOOL)_applicationShouldSendEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	UIView *touchedView = touch.view;
	NSArray *allowedViews = [[NSArray arrayWithObject:_contentViewController.view] arrayByAddingObjectsFromArray:_passthroughViews];
	
	for (UIView *view in allowedViews) {
		if ([touchedView isDescendantOfView:view]) {
			return YES;
		}
	}
	
	_manuallyDismissed = NO;
	[_popoverWindowController close];
	return NO;
}

@end
