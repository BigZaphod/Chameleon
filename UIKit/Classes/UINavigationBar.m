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

static const UIEdgeInsets kButtonEdgeInsets = {5,5,5,5};
static const CGFloat kMinButtonWidth = 30;
static const CGFloat kMaxButtonWidth = 200;
static const CGFloat kMaxButtonHeight = 24;

@implementation UINavigationBar
@synthesize tintColor=_tintColor, delegate=_delegate, items=_navStack;

+ (void)initialize
{
	if (self == [UINavigationBar class]) {
		ButtonImage = [[[UIImage _frameworkImageNamed:@"<UINavigationBar> button.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] retain];
		ButtonHighlightedImage = [[[UIImage _frameworkImageNamed:@"<UINavigationBar> button-highlighted.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] retain];
		BackButtonImage = [[[UIImage _frameworkImageNamed:@"<UINavigationBar> back.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:0] retain];
		BackButtonHighlightedImage = [[[UIImage _frameworkImageNamed:@"<UINavigationBar> back-highlighted.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:0] retain];
	}
}

+ (void)_setBarButtonSize:(UIView *)view
{
	CGRect frame = view.frame;
	frame.size = [view sizeThatFits:CGSizeMake(kMaxButtonWidth,kMaxButtonHeight)];
	frame.size.height = kMaxButtonHeight;
	frame.size.width = MAX(frame.size.width,kMinButtonWidth);
	view.frame = frame;
}

+ (UIButton *)_backButtonWithBarButtonItem:(UIBarButtonItem *)item
{
	if (!item) return nil;
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setBackgroundImage:BackButtonImage forState:UIControlStateNormal];
	[backButton setBackgroundImage:BackButtonHighlightedImage forState:UIControlStateHighlighted];
	[backButton setTitle:item.title forState:UIControlStateNormal];
	backButton.titleLabel.font = [UIFont systemFontOfSize:11];
	backButton.titleEdgeInsets = UIEdgeInsetsMake(0,15,0,7);
	[backButton addTarget:nil action:@selector(_backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self _setBarButtonSize:backButton];
	return backButton;
}

+ (UIView *)_viewWithBarButtonItem:(UIBarButtonItem *)item
{
	if (!item) return nil;

	if (item.customView) {
		[self _setBarButtonSize:item.customView];
		return item.customView;
	} else {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setBackgroundImage:ButtonImage forState:UIControlStateNormal];
		[button setBackgroundImage:ButtonHighlightedImage forState:UIControlStateHighlighted];
		[button setTitle:item.title forState:UIControlStateNormal];
		[button setImage:item.image forState:UIControlStateNormal];
		button.titleLabel.font = [UIFont systemFontOfSize:11];
		button.titleEdgeInsets = UIEdgeInsetsMake(0,7,0,7);
		[button addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
		[self _setBarButtonSize:button];
		return button;
	}
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_navStack = [NSMutableArray new];
		self.tintColor = [UIColor colorWithRed:21/255.f green:21/255.f blue:25/255.f alpha:1];
	}
	return self;
}

- (void)dealloc
{
	[_navStack release];
	[_tintColor release];
	[super dealloc];
}

- (void)setDelegate:(id)newDelegate
{
	_delegate = newDelegate;
	_delegateHas.shouldPushItem = [_delegate respondsToSelector:@selector(navigationBar:shouldPushItem:)];
	_delegateHas.didPushItem = [_delegate respondsToSelector:@selector(navigationBar:didPushItem:)];
	_delegateHas.shouldPopItem = [_delegate respondsToSelector:@selector(navigationBar:shouldPopItem:)];
	_delegateHas.didPopItem = [_delegate respondsToSelector:@selector(navigationBar:didPopItem:)];
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
		CGRect leftFrame = CGRectZero;
		CGRect rightFrame = CGRectZero;
		
		if (backItem) {
			_leftView = [isa _backButtonWithBarButtonItem:backItem.backBarButtonItem];
		} else {
			_leftView = [isa _viewWithBarButtonItem:topItem.leftBarButtonItem];
		}

		if (_leftView) {
			leftFrame = _leftView.frame;
			leftFrame.origin = CGPointMake(kButtonEdgeInsets.left, kButtonEdgeInsets.top);
			_leftView.frame = leftFrame;
			[self addSubview:_leftView];
		}

		_rightView = [isa _viewWithBarButtonItem:topItem.rightBarButtonItem];

		if (_rightView) {
			_rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
			rightFrame = _rightView.frame;
			rightFrame.origin.x = self.bounds.size.width-rightFrame.size.width - kButtonEdgeInsets.right;
			rightFrame.origin.y = kButtonEdgeInsets.top;
			_rightView.frame = rightFrame;
			[self addSubview:_rightView];
		}
		
		_centerView = topItem.titleView;

		if (!_centerView) {
			UILabel *titleLabel = [[UILabel new] autorelease];
			titleLabel.text = topItem.title;
			titleLabel.textAlignment = UITextAlignmentCenter;
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.textColor = [UIColor whiteColor];
			titleLabel.font = [UIFont systemFontOfSize:14];
			_centerView = titleLabel;
		}

		const CGFloat centerPadding = MAX(leftFrame.size.width, rightFrame.size.width);
		_centerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_centerView.frame = CGRectMake(kButtonEdgeInsets.left+centerPadding,kButtonEdgeInsets.top,self.bounds.size.width-kButtonEdgeInsets.right-kButtonEdgeInsets.left-centerPadding-centerPadding,kMaxButtonHeight);
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
	if (![_navStack isEqualToArray:items]) {
		[_navStack removeAllObjects];
		[_navStack addObjectsFromArray:items];
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

	if (_delegateHas.shouldPushItem) {
		shouldPush = [_delegate navigationBar:self shouldPushItem:item];
	}

	if (shouldPush) {
		[_navStack addObject:item];
		[self _updateViews:animated];
		
		if (_delegateHas.didPushItem) {
			[_delegate navigationBar:self didPushItem:item];
		}
	}
}

- (UINavigationItem *)popNavigationItemAnimated:(BOOL)animated
{
	UINavigationItem *previousItem = self.topItem;
	
	if (previousItem) {
		BOOL shouldPop = YES;

		if (_delegateHas.shouldPopItem) {
			shouldPop = [_delegate navigationBar:self shouldPopItem:previousItem];
		}
		
		if (shouldPop) {
			[previousItem retain];
			[_navStack removeObject:previousItem];
			[self _updateViews:animated];
			
			if (_delegateHas.didPopItem) {
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

	[[UIColor blackColor] setFill];
	UIRectFill(CGRectMake(0,bounds.size.height-1,bounds.size.width,1));
}

@end
