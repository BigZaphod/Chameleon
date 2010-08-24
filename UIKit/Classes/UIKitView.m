//  Created by Sean Heber on 6/19/10.
#import "UIKitView.h"
#import "UIApplication+UIPrivate.h"
#import "UIScreen+UIPrivate.h"
#import "UIWindow.h"
#import "UIImage.h"
#import "UIImageView.h"
#import "UIColor.h"

@implementation UIKitView
@synthesize UIScreen=_screen;

- (void)configureLayers
{
	[self setWantsLayer:YES];
	[self layer].backgroundColor = [UIColor whiteColor].CGColor;

	[[self layer] insertSublayer:[_screen _layer] atIndex:0];
	[_screen _layer].frame = [self layer].bounds;
	[_screen _layer].autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
}

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		_screen = [UIScreen new];
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
 
- (BOOL)isOpaque
{
	return YES;
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)viewDidMoveToSuperview
{	
	[_screen _setNSView:self.superview? self : nil];
}

- (void)updateTrackingAreas
{
	[super updateTrackingAreas];
	[self removeTrackingArea:_trackingArea];
	[_trackingArea release];
	_trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingCursorUpdate|NSTrackingMouseMoved|NSTrackingInVisibleRect|NSTrackingActiveInActiveApp owner:self userInfo:nil];
	[self addTrackingArea:_trackingArea];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)scrollWheel:(NSEvent *)theEvent
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
