//  Created by Sean Heber on 6/19/10.
#import "UIKitView.h"
#import "UIScreen.h"
#import "UIApplication.h"
#import "UIKit+Private.h"

@implementation UIKitView
@synthesize screen=_screen;

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		_screen = [UIScreen new];
		[self setLayer:[_screen _layer]];
		[self setWantsLayer:YES];
    }
    return self;
}

- (void)dealloc
{
	[_screen release];
	[super dealloc];
}

- (void)awakeFromNib
{
	[self setWantsLayer:YES];
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

@end
