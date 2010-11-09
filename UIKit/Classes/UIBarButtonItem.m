//  Created by Sean Heber on 6/25/10.
#import "UIBarButtonItem.h"

@implementation UIBarButtonItem
@synthesize width=_width, customView=_customView, action=_action, target=_target, style=_style;

- (id)init
{
	if ((self=[super init])) {
		_isSystemItem = NO;
		self.style = UIBarButtonItemStylePlain;
	}
	return self;
}

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action
{
	if ((self=[self init])) {
		_isSystemItem = YES;
		_systemItem = systemItem;

		self.target = target;
		self.action = action;
	}
	return self;
}

- (id)initWithCustomView:(UIView *)customView
{
	if ((self=[self init])) {
		self.customView = customView;
	}
	return self;
}

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
	if ((self=[self init])) {
		self.title = title;
		self.style = style;
		self.target = target;
		self.action = action;
	}
	return self;
}

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
	if ((self=[self init])) {
		self.image = image;
		self.style = style;
		self.target = target;
		self.action = action;
	}
	return self;
}

- (void)dealloc
{
	[_customView release];
	[super dealloc];
}

- (UIView *)customView
{
	return _isSystemItem? nil : _customView;
}

@end
