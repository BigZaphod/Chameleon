//  Created by Sean Heber on 6/25/10.
#import "UINavigationBar.h"
#import "UIGraphics.h"
#import "UIColor.h"
#import "UILabel.h"
#import "UINavigationItem.h"
#import "UIFont.h"
#import "UIImage+UIPrivate.h"
#import "UIBarButtonItem.h"
#import "UIButton.h"

static UIImage *ButtonImage = nil;
static UIImage *ButtonHighlightedImage = nil;
static UIImage *BackButtonImage = nil;
static UIImage *BackButtonHighlightedImage = nil;

@implementation UINavigationBar
@synthesize tintColor=_tintColor, delegate=_delegate, items=_items;

+ (void)initialize
{
	if (self == [UINavigationBar class]) {
		ButtonImage = [[[UIImage _frameworkImageNamed:@"<UINavigationBar> button.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] retain];
		ButtonHighlightedImage = [[[UIImage _frameworkImageNamed:@"<UINavigationBar> button-highlighted.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] retain];
		BackButtonImage = [[[UIImage _frameworkImageNamed:@"<UINavigationBar> back.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:0] retain];
		BackButtonHighlightedImage = [[[UIImage _frameworkImageNamed:@"<UINavigationBar> back-highlighted.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:0] retain];
	}
}

+ (UIButton *)_backButtonWithBarButtonItem:(UIBarButtonItem *)item
{
	if (!item) return nil;
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setBackgroundImage:BackButtonImage forState:UIControlStateNormal];
	[backButton setBackgroundImage:BackButtonHighlightedImage forState:UIControlStateHighlighted];
	[backButton setTitle:item.title forState:UIControlStateNormal];
	backButton.titleLabel.font = [UIFont systemFontOfSize:11];
	backButton.titleEdgeInsets = UIEdgeInsetsMake(4,15,4,4);
	[backButton addTarget:nil action:@selector(_backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	return backButton;
}

+ (UIButton *)_buttonWithBarButtonItem:(UIBarButtonItem *)item
{
	if (!item) return nil;
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage:ButtonImage forState:UIControlStateNormal];
	[button setBackgroundImage:ButtonHighlightedImage forState:UIControlStateHighlighted];
	[button setTitle:item.title forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont systemFontOfSize:11];
	button.titleEdgeInsets = UIEdgeInsetsMake(4,4,4,4);
	[button addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_navStack = [NSMutableArray new];
		self.tintColor = [UIColor colorWithWhite:0.133f alpha:1];
	}
	return self;
}

- (void)dealloc
{
	[_items release];
	[_navStack release];
	[_tintColor release];
	[super dealloc];
}

- (UINavigationItem *)topItem
{
	return [_navStack lastObject];
}

- (UINavigationItem *)backItem
{
	return ([_navStack count] <= 1)? nil : [_navStack objectAtIndex:[_navStack count]-2];
}

- (void)_backButtonTapped:(id)sender
{
	[self popNavigationItemAnimated:YES];
}

- (void)_updateViews:(BOOL)animated
{
	[_leftView removeFromSuperview];
	[_centerView removeFromSuperview];
	[_rightView removeFromSuperview];
	
	UINavigationItem *topItem = self.topItem;
	UINavigationItem *backItem = self.backItem;
	
	if (topItem) {
		const CGFloat minButtonWidth = 30;
		const CGFloat maxButtonWidth = 200;
		const CGFloat maxButtonHeight = 24;
		UIEdgeInsets edgePadding = UIEdgeInsetsMake(4,4,0,4);
		
		if (backItem) {
			_leftView = [isa _backButtonWithBarButtonItem:backItem.backBarButtonItem];
		} else {
			_leftView = [isa _buttonWithBarButtonItem:topItem.leftBarButtonItem];
		}

		CGSize leftSize = [_leftView sizeThatFits:CGSizeMake(maxButtonWidth,maxButtonHeight)];
		leftSize.height = maxButtonHeight;
		leftSize.width = MAX(leftSize.width,minButtonWidth);
		_leftView.frame = CGRectMake(edgePadding.left,edgePadding.top,leftSize.width,leftSize.height);
		[self addSubview:_leftView];

		_rightView = [isa _buttonWithBarButtonItem:topItem.rightBarButtonItem];
		_rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		CGSize rightSize = [_rightView sizeThatFits:CGSizeMake(maxButtonWidth,maxButtonHeight)];
		rightSize.height = maxButtonHeight;
		rightSize.width = MAX(rightSize.width,minButtonWidth);
		_rightView.frame = CGRectMake(self.bounds.size.width-rightSize.width-edgePadding.right,edgePadding.top,rightSize.width,rightSize.height);
		[self addSubview:_rightView];
		
		_centerView = topItem.titleView;

		if (!_centerView) {
			UILabel *titleLabel = [[UILabel new] autorelease];
			titleLabel.text = topItem.title;
			titleLabel.textAlignment = UITextAlignmentCenter;
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.textColor = [UIColor whiteColor];
			titleLabel.font = [UIFont boldSystemFontOfSize:17];
			_centerView = titleLabel;
		}

		_centerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_centerView.frame = CGRectMake(leftSize.width+edgePadding.left,edgePadding.top,self.bounds.size.width-leftSize.width-rightSize.width-edgePadding.left-edgePadding.right,maxButtonHeight);
		[self addSubview:_centerView];
	} else {
		_leftView = _centerView = _rightView = nil;
	}
}

- (void)setTintColor:(UIColor *)newColor
{
	if (newColor != _tintColor) {
		[_tintColor release];
		_tintColor = [newColor retain];
		[self setNeedsDisplay];
	}
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
	if (items != _items) {
		[_items release];
		_items = [items copy];
		[self _updateViews:animated];
	}
}

- (void)setItems:(NSArray *)items
{
	[self setItems:items animated:NO];
}

- (void)pushNavigationItem:(UINavigationItem *)item animated:(BOOL)animated
{
	BOOL shouldPush = YES;

	if ([_delegate respondsToSelector:@selector(navigationBar:shouldPushItem:)]) {
		shouldPush = [_delegate navigationBar:self shouldPushItem:item];
	}

	if (shouldPush) {
		[_navStack addObject:item];
		[self _updateViews:animated];
		
		if ([_delegate respondsToSelector:@selector(navigationBar:didPushItem:)]) {
			[_delegate navigationBar:self didPushItem:item];
		}
	}
}

- (UINavigationItem *)popNavigationItemAnimated:(BOOL)animated
{
	UINavigationItem *previousItem = self.topItem;
	
	if (previousItem) {
		BOOL shouldPop = YES;

		if ([_delegate respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
			shouldPop = [_delegate navigationBar:self shouldPopItem:previousItem];
		}
		
		if (shouldPop) {
			[previousItem retain];
			[_navStack removeObject:previousItem];
			[self _updateViews:animated];
			
			if ([_delegate respondsToSelector:@selector(navigationBar:didPopItem:)]) {
				[_delegate navigationBar:self didPopItem:previousItem];
			}
			
			return [previousItem autorelease];
		}
	}
	
	return nil;
}

- (void)drawRect:(CGRect)rect
{
	const CGRect bounds = self.bounds;
	
	// I kind of suspect that the "right" thing to do is to draw the background and then paint over it with the tintColor doing some kind of blending
	// so that it actually doesn "tint" the image instead of define it. That'd probably work better with the bottom line coloring and stuff, too, but
	// for now hardcoding stuff works well enough.
	
	[_tintColor setFill];
	UIRectFill(bounds);

	[[UIColor colorWithWhite:0.29f alpha:1] setFill];
	UIRectFill(CGRectMake(0,bounds.size.height-1,bounds.size.width,1));
}

@end
