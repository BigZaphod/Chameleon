//  Created by Sean Heber on 6/25/10.
#import "UIBarButtonItem.h"

@implementation UIBarButtonItem
@synthesize width=_width, customView=_customView, action=_action, target=_target;

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action
{
	if ((self=[super init])) {
	}
	return self;
}

- (id)initWithCustomView:(UIView *)customView
{
	if ((self=[super init])) {
	}
	return self;
}

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
	if ((self=[super init])) {
	}
	return self;
}

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
	if ((self=[super init])) {
	}
	return self;
}

- (void)dealloc
{
	[_customView release];
	[super dealloc];
}

@end
