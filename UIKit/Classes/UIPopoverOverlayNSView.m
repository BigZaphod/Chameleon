//  Created by Sean Heber on 10/15/10.
#import "UIPopoverOverlayNSView.h"
#import "UIPopoverController+UIPrivate.h"

@implementation UIPopoverOverlayNSView

- (id)initWithFrame:(NSRect)frame popoverController:(UIPopoverController *)controller
{
	if ((self=[super initWithFrame:frame])) {
		_popoverController = controller;
	}
	return self;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (BOOL)canBecomeKeyView
{
	return NO;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[_popoverController _closePopoverWindowIfPossible];
}

@end
