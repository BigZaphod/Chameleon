//  Created by Sean Heber on 6/25/10.
#import "UINavigationItem.h"
#import "UIBarButtonItem.h"

@implementation UINavigationItem
@synthesize title=_title, rightBarButtonItem=_rightBarButtonItem, titleView=_titleView, hidesBackButton=_hidesBackButton;
@synthesize leftBarButtonItem=_leftBarButtonItem, backBarButtonItem=_backBarButtonItem;

- (id)initWithTitle:(NSString *)theTitle
{
	if ((self=[super init])) {
		self.title = theTitle;
	}
	return self;
}

- (void)dealloc
{
	[_backBarButtonItem release];
	[_leftBarButtonItem release];
	[_rightBarButtonItem release];
	[_title release];
	[_titleView release];
	[super dealloc];
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
}

- (void)setHidesBackButton:(BOOL)hidesBackButton animated:(BOOL)animated
{
	_hidesBackButton = hidesBackButton;
}

- (void)setHidesBackButton:(BOOL)hidesBackButton
{
	[self setHidesBackButton:hidesBackButton animated:NO];
}

- (UIBarButtonItem *)backBarButtonItem
{
	if (_backBarButtonItem) {
		return _backBarButtonItem;
	} else {
		return [[[UIBarButtonItem alloc] initWithTitle:(self.title ?: @"Back") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	}
}

@end
