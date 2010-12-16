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

static const UIEdgeInsets kButtonEdgeInsets = {0,0,0,0};
static const CGFloat kMinButtonWidth = 30;
static const CGFloat kMaxButtonWidth = 200;
static const CGFloat kMaxButtonHeight = 24;

static const NSTimeInterval kAnimationDuration = 0.33;

typedef enum {
	_UINavigationBarTransitionPush,
	_UINavigationBarTransitionPop
} _UINavigationBarTransition;

@implementation UINavigationBar
@synthesize tintColor=_tintColor, delegate=_delegate, items=_navStack;

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
	[backButton setBackgroundImage:[UIImage _backButtonImage] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage _highlightedBackButtonImage] forState:UIControlStateHighlighted];
	[backButton setTitle:item.title forState:UIControlStateNormal];
	backButton.titleLabel.font = [UIFont systemFontOfSize:11];
	backButton.contentEdgeInsets = UIEdgeInsetsMake(0,15,0,7);
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
		[button setBackgroundImage:[UIImage _toolbarButtonImage] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage _highlightedToolbarButtonImage] forState:UIControlStateHighlighted];
		[button setTitle:item.title forState:UIControlStateNormal];
		[button setImage:item.image forState:UIControlStateNormal];
		button.titleLabel.font = [UIFont systemFontOfSize:11];
		button.contentEdgeInsets = UIEdgeInsetsMake(0,7,0,7);
		[button addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
		[self _setBarButtonSize:button];
		return button;
	}
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_navStack = [[NSMutableArray alloc] init];
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

- (void)_removeAnimatedViews:(NSArray *)views
{
	[views makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[views release];
}

- (void)_setViewsWithTransition:(_UINavigationBarTransition)transition animated:(BOOL)animated
{
	{
		NSMutableArray *previousViews = [[NSMutableArray alloc] init];
		if (_leftView) [previousViews addObject:_leftView];
		if (_centerView) [previousViews addObject:_centerView];
		if (_rightView) [previousViews addObject:_rightView];

		if (animated) {
			CGFloat moveCenterBy = self.bounds.size.width - _centerView.frame.origin.x;
			CGFloat moveLeftBy = self.bounds.size.width * 0.33f;

			if (transition == _UINavigationBarTransitionPush) {
				moveCenterBy *= -1.f;
				moveLeftBy *= -1.f;
			}
			
			[UIView beginAnimations:@"move out" context:NULL];
			[UIView setAnimationDuration:kAnimationDuration];
			_leftView.frame = CGRectOffset(_leftView.frame, moveLeftBy, 0);
			_centerView.frame = CGRectOffset(_centerView.frame, moveCenterBy, 0);
			[UIView commitAnimations];

			[UIView beginAnimations:@"fade out" context:NULL];
			[UIView setAnimationDuration:kAnimationDuration * .8];
			[UIView setAnimationDelay:kAnimationDuration * .2];
			_leftView.alpha = 0;
			_rightView.alpha = 0;
			_centerView.alpha = 0;
			[UIView commitAnimations];
			
			[self performSelector:@selector(_removeAnimatedViews:) withObject:previousViews afterDelay:kAnimationDuration];
		} else {
			[self _removeAnimatedViews:previousViews];
		}
	}
	
	UINavigationItem *topItem = self.topItem;
	
	if (topItem) {
		UINavigationItem *backItem = self.backItem;

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
			UILabel *titleLabel = [[[UILabel alloc] init] autorelease];
			titleLabel.text = topItem.title;
			titleLabel.textAlignment = UITextAlignmentCenter;
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.textColor = [UIColor whiteColor];
			titleLabel.font = [UIFont boldSystemFontOfSize:14];
			_centerView = titleLabel;
		}

		const CGFloat centerPadding = MAX(leftFrame.size.width, rightFrame.size.width);
		_centerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_centerView.frame = CGRectMake(kButtonEdgeInsets.left+centerPadding,kButtonEdgeInsets.top,self.bounds.size.width-kButtonEdgeInsets.right-kButtonEdgeInsets.left-centerPadding-centerPadding,kMaxButtonHeight);
		[self addSubview:_centerView];

		if (animated) {
			CGFloat moveCenterBy = self.bounds.size.width - _centerView.frame.origin.x;
			CGFloat moveLeftBy = self.bounds.size.width * 0.33f;

			if (transition == _UINavigationBarTransitionPush) {
				moveLeftBy *= -1.f;
				moveCenterBy *= -1.f;
			}

			CGRect destinationLeftFrame = _leftView.frame;
			CGRect destinationCenterFrame = _centerView.frame;
			
			_leftView.frame = CGRectOffset(_leftView.frame, -moveLeftBy, 0);
			_centerView.frame = CGRectOffset(_centerView.frame, -moveCenterBy, 0);
			_leftView.alpha = 0;
			_rightView.alpha = 0;
			_centerView.alpha = 0;
			
			[UIView beginAnimations:@"move in" context:NULL];
			[UIView setAnimationDuration:kAnimationDuration];
			_leftView.frame = destinationLeftFrame;
			_centerView.frame = destinationCenterFrame;
			[UIView commitAnimations];
			
			[UIView beginAnimations:@"fade in" context:NULL];
			[UIView setAnimationDuration:kAnimationDuration * .8];
			[UIView setAnimationDelay:kAnimationDuration * .2];
			_leftView.alpha = 1;
			_rightView.alpha = 1;
			_centerView.alpha = 1;
			[UIView commitAnimations];
		}		
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
		[self _setViewsWithTransition:_UINavigationBarTransitionPush animated:animated];
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
		[self _setViewsWithTransition:_UINavigationBarTransitionPush animated:animated];
		
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
			[self _setViewsWithTransition:_UINavigationBarTransitionPop animated:animated];
			
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
