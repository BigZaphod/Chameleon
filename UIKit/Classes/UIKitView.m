//  Created by Sean Heber on 6/19/10.
#import "UIKitView.h"
#import "UIApplication+UIPrivate.h"
#import "UIScreen+UIPrivate.h"
#import "UIWindow+UIPrivate.h"
#import "UIImage.h"
#import "UIImageView.h"
#import "UIColor.h"

@implementation UIKitView
@synthesize UIScreen=_screen;

- (void)configureLayers
{
	[self setWantsLayer:YES];

	[[self layer] insertSublayer:[_screen _layer] atIndex:0];
	[_screen _layer].frame = [self layer].bounds;
	[_screen _layer].autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
}

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		_screen = [[UIScreen alloc] init];
		[self configureLayers];
    }
    return self;
}

- (void)dealloc
{
	[_screen release];
	[_mainWindow release];
	[super dealloc];
}

- (UIWindow *)UIWindow
{
	if (!_mainWindow) {
		_mainWindow = [(UIWindow *)[UIWindow alloc] initWithFrame:_screen.bounds];
		_mainWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_mainWindow.screen = _screen;
		[_mainWindow makeKeyAndVisible];
	}
	
	return _mainWindow;
}

- (void)awakeFromNib
{
	[self configureLayers];
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)viewDidMoveToSuperview
{	
	[_screen _setUIKitView:self.superview? self : nil];
}

- (UIResponder *)_firstUIKitResponder
{
	UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
	if (keyWindow.screen == _screen) {
		return [keyWindow _firstResponder];
	} else {
		return nil;
	}
}

- (BOOL)acceptsFirstResponder
{
	return ([self _firstUIKitResponder] != nil);
}

- (BOOL)firstResponderCanPerformAction:(SEL)action withSender:(id)sender
{
	return [[self _firstUIKitResponder] canPerformAction:action withSender:sender];
}

- (void)sendActionToFirstResponder:(SEL)action from:(id)sender
{
	[[self _firstUIKitResponder] performSelector:action withObject:sender];
}

- (BOOL)respondsToSelector:(SEL)cmd
{
	if (cmd == @selector(copy:) ||
		cmd == @selector(cut:) ||
		cmd == @selector(delete:) ||
		cmd == @selector(paste:) ||
		cmd == @selector(select:) ||
		cmd == @selector(selectAll:)) {
		return [self firstResponderCanPerformAction:cmd withSender:nil];
	} else {
		return [super respondsToSelector:cmd];
	}
}

- (void)copy:(id)sender			{ [self sendActionToFirstResponder:_cmd from:sender]; }
- (void)cut:(id)sender			{ [self sendActionToFirstResponder:_cmd from:sender]; }
- (void)delete:(id)sender		{ [self sendActionToFirstResponder:_cmd from:sender]; }
- (void)paste:(id)sender		{ [self sendActionToFirstResponder:_cmd from:sender]; }
- (void)select:(id)sender		{ [self sendActionToFirstResponder:_cmd from:sender]; }
- (void)selectAll:(id)sender	{ [self sendActionToFirstResponder:_cmd from:sender]; }

- (void)updateTrackingAreas
{
	[super updateTrackingAreas];
	[self removeTrackingArea:_trackingArea];
	[_trackingArea release];
	_trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingCursorUpdate|NSTrackingMouseMoved|NSTrackingInVisibleRect|NSTrackingActiveInKeyWindow|NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
	[self addTrackingArea:_trackingArea];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if ([theEvent modifierFlags] & NSControlKeyMask) {
		// I don't really like this, but it seemed to be necessary.
		// If I override the menuForEvent: method, when you control-click it *still* sends mouseDown:, so I don't
		// really win anything by overriding that since I'd still need a check in here to prevent that mouseDown: from being
		// sent to UIKit as a touch. That seems really wrong, IMO. A right click should be independent of a touch event.
		// soooo.... here we are. Whatever. Seems to work. Don't really like it.
		NSEvent *newEvent = [NSEvent mouseEventWithType:NSRightMouseDown location:[theEvent locationInWindow] modifierFlags:0 timestamp:[theEvent timestamp] windowNumber:[theEvent windowNumber] context:[theEvent context] eventNumber:[theEvent eventNumber] clickCount:[theEvent clickCount] pressure:[theEvent pressure]];
		[self rightMouseDown:newEvent];
	} else {
		[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)_launchApplicationDelegate:(id<UIApplicationDelegate>)appDelegate
{
	UIApplication *app = [UIApplication sharedApplication];
	[app setDelegate:appDelegate];

	if ([appDelegate respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]) {
		[appDelegate application:app didFinishLaunchingWithOptions:nil];
	} else if ([appDelegate respondsToSelector:@selector(applicationDidFinishLaunching:)]) {
		[appDelegate applicationDidFinishLaunching:app];
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidFinishLaunchingNotification object:app];

	if ([appDelegate respondsToSelector:@selector(applicationDidBecomeActive:)]) {
		[appDelegate applicationDidBecomeActive:app];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:app];
}

- (void)_releaseDefaultWindow:(UIWindow *)defaultWindow
{
	[defaultWindow release];
}

- (void)launchApplicationWithDelegate:(id<UIApplicationDelegate>)appDelegate afterDelay:(NSTimeInterval)delay
{
	if (delay) {
		UIImage *defaultImage = [UIImage imageNamed:@"Default-Landscape.png"];
		UIImageView *defaultImageView = [[[UIImageView alloc] initWithImage:defaultImage] autorelease];
		defaultImageView.contentMode = UIViewContentModeCenter;
		
		UIWindow *defaultWindow = [(UIWindow *)[UIWindow alloc] initWithFrame:_screen.bounds];
		defaultWindow.screen = _screen;
		defaultWindow.backgroundColor = [UIColor blackColor];	// dunno..
		defaultWindow.opaque = YES;
		[defaultWindow addSubview:defaultImageView];
		[defaultWindow makeKeyAndVisible];
		
		[self performSelector:@selector(_launchApplicationDelegate:) withObject:appDelegate afterDelay:delay];
		[self performSelector:@selector(_releaseDefaultWindow:) withObject:defaultWindow afterDelay:delay];
	} else {
		[self _launchApplicationDelegate:appDelegate];
	}
}

@end
