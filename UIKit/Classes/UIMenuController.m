//  Created by Sean Heber on 8/31/10.
#import "UIMenuController.h"
#import "UIApplication.h"
#import "UIWindow+UIPrivate.h"
#import "UIScreen+UIPrivate.h"
#import "UIMenuItem.h"
#import <AppKit/NSMenu.h>
#import <AppKit/NSMenuItem.h>
#import <AppKit/NSApplication.h>

@interface UIMenuController () <NSMenuDelegate>
@end

@implementation UIMenuController
@synthesize menuItems=_menuItems, menuFrame=_menuFrame;

+ (UIMenuController *)sharedMenuController
{
	static UIMenuController *controller = nil;
	return controller ?: (controller = [UIMenuController new]);
}

+ (NSArray *)_defaultMenuItems
{
	static NSArray *items = nil;

	if (!items) {
		items = [[NSArray alloc] initWithObjects:
				 [[[UIMenuItem alloc] initWithTitle:@"Cut" action:@selector(cut:)] autorelease],
				 [[[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copy:)] autorelease],
				 [[[UIMenuItem alloc] initWithTitle:@"Paste" action:@selector(paste:)] autorelease],
				 [[[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(delete:)] autorelease],
				 [[[UIMenuItem alloc] initWithTitle:@"Select" action:@selector(select:)] autorelease],
				 [[[UIMenuItem alloc] initWithTitle:@"Select All" action:@selector(selectAll:)] autorelease],
				 nil];
	}

	return items;
}


- (id)init
{
	if ((self=[super init])) {
		_enabledMenuItems = [NSMutableArray new];
	}
	return self;
}

- (void)dealloc
{
	[_menuItems release];
	[_enabledMenuItems release];
	[_menu cancelTracking];		// this should never really happen since the controller is pretty much always a singleton, but... whatever.
	[_menu release];
	[super dealloc];
}

- (BOOL)isMenuVisible
{
	return (_menu != nil);
}

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated
{
	const BOOL wasVisible = [self isMenuVisible];

	if (menuVisible && !wasVisible) {
		[self update];

		if ([_enabledMenuItems count] > 0) {
			_menu = [[NSMenu alloc] initWithTitle:@""];
			[_menu setDelegate:self];
			[_menu setAutoenablesItems:NO];
			[_menu setAllowsContextMenuPlugIns:NO];
			
			for (UIMenuItem *item in _enabledMenuItems) {
				NSMenuItem *theItem = [[NSMenuItem alloc] initWithTitle:item.title action:@selector(_didSelectMenuItem:) keyEquivalent:@""];
				[theItem setTarget:self];
				[theItem setRepresentedObject:item];
				[_menu addItem:theItem];
				[theItem release];
			}
			
			// this is offset so that it seems to be aligned on the right of the initial rect given to setTargetRect:inView:
			// I don't know if this is the best behavior yet or not.
			_menuFrame.size = NSSizeToCGSize([_menu size]);
			_menuFrame.origin = _menuLocation;
			_menuFrame.origin.x -= _menuFrame.size.width;
			
			// note that presenting an NSMenu is apparently modal. so, to pretend that it isn't, exactly, I'll delay the presentation
			// of the menu to the start of a new runloop. At least that way, code that may be expecting to run right after setting the
			// menu to visible would still run before the menu itself shows up on screen. Of course behavior is going to be pretty different
			// after that point since if the app is assuming it can keep on doing normal runloop stuff, it ain't gonna happen.
			// but since clicks outside of an NSMenu dismiss it, there's not a lot a user can do to an app to change state when a menu
			// is up in the first place.
			[self performSelector:@selector(_presentMenu) withObject:nil afterDelay:0];
		}
	} else if (!menuVisible && wasVisible) {
		// make it unhappen
		if (animated) {
			[_menu cancelTracking];
		} else {
			[_menu cancelTrackingWithoutAnimation];
		}
		[_menu release];
		_menu = nil;
	}
}

- (void)setMenuVisible:(BOOL)visible
{
	[self setMenuVisible:visible animated:NO];
}

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView
{
	// we have to have some window somewhere to use as a basis, so if there isn't a view, we'll just use the
	// keyWindow and go from there.
	_window = targetView.window ?: [UIApplication sharedApplication].keyWindow;

	// this will ultimately position the menu under the lower right of the given rectangle.
	// but it is then shifted in setMenuVisible:animated: so that the menu is right-aligned with the given rect.
	// this is all rather strange, perhaps, but it made sense at the time. we'll see if it does in practice.
	targetRect.origin.x += targetRect.size.width;
	targetRect.origin.y += targetRect.size.height;
	
	// first convert to screen coord, otherwise assume it already is, I guess, only the catch with targetView being nil
	// is that the assumed screen might not be the keyWindow's screen, which is what I'm going to be assuming here.
	// but bah - who cares? :)
	if (targetView) {
		targetRect = [_window convertRect:[_window convertRect:targetRect fromView:targetView] toWindow:nil];
	}
	
	// only the origin is being set here. the size isn't known until the menu is created, which happens in setMenuVisible:animated:
	// so that's where _menuFrame will actually be configured for now.
	_menuLocation = targetRect.origin;
}

- (void)update
{
	UIApplication *app = [UIApplication sharedApplication];
	UIResponder *firstResponder = [app.keyWindow _firstResponder];
	NSArray *allItems = [[isa _defaultMenuItems] arrayByAddingObjectsFromArray:_menuItems];

	[_enabledMenuItems removeAllObjects];

	if (firstResponder) {
		for (UIMenuItem *item in allItems) {
			if ([firstResponder canPerformAction:item.action withSender:app]) {
				[_enabledMenuItems addObject:item];
			}
		}
	}
}

- (void)_presentMenu
{
	if (_menu && _window) {
		NSView *theNSView = [_window.screen _NSView];
		if (theNSView) {
			[_menu popUpMenuPositioningItem:nil atLocation:NSPointFromCGPoint(_menuFrame.origin) inView:theNSView];
		}
	}
}

- (void)_didSelectMenuItem:(NSMenuItem *)sender
{
	// the docs say that it calls -update when it detects a touch in the menu, so I assume it does this to try to prevent actions being sent
	// that perhaps have just been un-enabled due to something else that happened since the menu first appeared. To replicate that, I'll just
	// call update again here to rebuild the list of allowed actions and then do one final check to make sure that the requested action has
	// not been disabled out from under us.
	[self update];
	
	UIApplication *app = [UIApplication sharedApplication];
	UIResponder *firstResponder = [app.keyWindow _firstResponder];
	UIMenuItem *selectedItem = [sender representedObject];

	// now spin through the enabled actions, make sure the selected one is still in there, and then send it if it is.
	if (firstResponder && selectedItem) {
		for (UIMenuItem *item in _enabledMenuItems) {
			if (item.action == selectedItem.action) {
				[app sendAction:item.action to:firstResponder from:app forEvent:nil];
				break;
			}
		}
	}
}

- (void)menuDidClose:(NSMenu *)menu
{
	if (menu == _menu) {
		[_menu release];
		_menu = nil;
	}
}


@end
