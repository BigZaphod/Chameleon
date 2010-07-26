//  Created by Sean Heber on 6/25/10.
#import "UIActionSheet.h"

@implementation UIActionSheet
@synthesize delegate=_delegate, destructiveButtonIndex=_destructiveButtonIndex, visible=_visible, cancelButtonIndex=_cancelButtonIndex, title=_title;

- (id)initWithTitle:(NSString *)title delegate:(id < UIActionSheetDelegate >)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
	if ((self=[super initWithFrame:CGRectZero])) {
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (NSInteger)addButtonWithTitle:(NSString *)title
{
	return 0;
}

- (void)showInView:(UIView *)view
{
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated
{
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
}

@end
