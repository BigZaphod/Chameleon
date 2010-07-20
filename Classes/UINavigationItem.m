//  Created by Sean Heber on 6/25/10.
#import "UINavigationItem.h"

@implementation UINavigationItem
@synthesize title=_title, rightBarButtonItem=_rightBarButtonItem, titleView=_titleView, hidesBackButton=_hidesBackButton;

- (id)initWithTitle:(NSString *)theTitle
{
	if ((self=[super init])) {
		self.title = theTitle;
	}
	return self;
}

- (void)dealloc
{
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

@end
