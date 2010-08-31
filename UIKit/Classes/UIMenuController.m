//  Created by Sean Heber on 8/31/10.
#import "UIMenuController.h"

@implementation UIMenuController
@synthesize menuItems=_menuItems;

+ (UIMenuController *)sharedMenuController
{
	return nil;
}

- (void)dealloc
{
	[_menuItems release];
	[super dealloc];
}

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated
{
}

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView
{
}

@end
