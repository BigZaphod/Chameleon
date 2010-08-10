//  Created by Sean Heber on 6/25/10.
#import "UIPopoverController.h"
#import "_UIPopoverWindow.h"
#import "_UIPopoverWindowController.h"
#import "UIViewController.h"
#import "UIWindow.h"
#import "UIScreen.h"
#import "UIKitView.h"

@implementation UIPopoverController
@synthesize delegate=_delegate, contentViewController=_contentViewController, popoverVisible=_popoverVisible;

- (id)init
{
	if ((self=[super init])) {
		NSRect defaultFrame = NSMakeRect(0, 0, 320.0f, 480.0f);
		
		_UIKitView = [[UIKitView alloc] initWithFrame:defaultFrame];
		
		_UIPopoverWindow *popoverWindow = [[[_UIPopoverWindow alloc] initWithContentRect:defaultFrame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES] autorelease];
		_popoverWindowController = [[_UIPopoverWindowController alloc] initWithWindow:popoverWindow];
		
		[popoverWindow setDelegate:_popoverWindowController];
		[popoverWindow setTitle:@"Popover"];
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
	[_UIKitView release];
	[_popoverWindowController release];
	[_contentViewController release];
	[super dealloc];
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
	
	[(_UIPopoverWindow *)[_popoverWindowController window] setFrameForContentSize:NSMakeSize(320.0f, 480.0f) atPoint:desktopWindowPoint inWindow:[_UIKitView window]];

	_contentViewController.view.frame = [_UIKitView UIWindow].bounds;
	
	[_popoverWindowController showWindow:self];
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
}

@end
