//  Created by Sean on 10/14/10.
#import "UIPopoverNSWindow.h"
#import "UIPopoverController+UIPrivate.h"

@implementation UIPopoverNSWindow

- (void)setPopoverController:(UIPopoverController *)controller
{
	_popoverController = controller;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (void)cancelOperation:(id)sender
{
	[_popoverController _closePopoverWindowIfPossible];
}

@end
