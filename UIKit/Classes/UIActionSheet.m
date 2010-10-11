//  Created by Sean Heber on 6/25/10.
#import "UIActionSheet.h"
#import "UIWindow.h"
#import "UIScreen+UIPrivate.h"
#import "UIButton.h"
#import "UIViewController.h"
#import "UIPopoverController.h"

@interface UIActionSheet () <UIPopoverControllerDelegate>
@end

@implementation UIActionSheet
@synthesize delegate=_delegate, destructiveButtonIndex=_destructiveButtonIndex, cancelButtonIndex=_cancelButtonIndex, title=_title;

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_buttons = [NSMutableArray new];
		_destructiveButtonIndex = -1;
		_cancelButtonIndex = -1;
	}
	return self;
}

- (id)initWithTitle:(NSString *)title delegate:(id < UIActionSheetDelegate >)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
	if ((self=[self initWithFrame:CGRectZero])) {
		self.delegate = delegate;
		
		if (cancelButtonTitle) {
			self.cancelButtonIndex = [self addButtonWithTitle:cancelButtonTitle];
		}
		
		if (destructiveButtonTitle) {
			self.destructiveButtonIndex = [self addButtonWithTitle:destructiveButtonTitle];
		}
		
		if (otherButtonTitles) {
			[self addButtonWithTitle:otherButtonTitles];

			id buttonTitle = nil;
			va_list argumentList;
			va_start(argumentList, otherButtonTitles);

			while ((buttonTitle=va_arg(argumentList, NSString *))) {
				[self addButtonWithTitle:buttonTitle];
			}
			
			va_end(argumentList);
		}
	}
	return self;
}

- (void)dealloc
{
	[_buttons release];
	[super dealloc];
}

- (void)setDelegate:(id<UIActionSheetDelegate>)newDelegate
{
	_delegate = newDelegate;
	_delegateHas.clickedButtonAtIndex = [_delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)];
	_delegateHas.willPresentActionSheet = [_delegate respondsToSelector:@selector(willPresentActionSheet:)];
	_delegateHas.didPresentActionSheet = [_delegate respondsToSelector:@selector(didPresentActionSheet:)];
	_delegateHas.willDismissWithButtonIndex = [_delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)];
	_delegateHas.didDismissWithButtonIndex = [_delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)];
	_delegateHas.actionSheetCancel = [_delegate respondsToSelector:@selector(actionSheetCancel:)];
}

- (CGSize)_viewSize
{
	return CGSizeMake(320, [_buttons count]*40);
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	const CGFloat width = self.bounds.size.width;
	const CGFloat buttonHeight = 40;
	const CGFloat buttonSpacer = 2;
	CGFloat y = 0;
	
	for (UIButton *button in _buttons) {
		button.frame = CGRectMake(0,y,width,buttonHeight);
		y+= buttonHeight + buttonSpacer;
	}
}

- (NSInteger)addButtonWithTitle:(NSString *)title
{
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btn addTarget:nil action:@selector(_buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTitle:title forState:UIControlStateNormal];
	
	[_buttons addObject:btn];
	[self addSubview:btn];

	return [_buttons count]-1;
}

- (void)setDestructiveButtonIndex:(NSInteger)index
{
	if (index != _destructiveButtonIndex) {
		if (index >= 0) {
			NSAssert(index<[_buttons count],nil,nil);
		} else {
			index = -1;
		}

		_destructiveButtonIndex = index;
	}
}

- (void)setCancelButtonIndex:(NSInteger)index
{
	if (index != _cancelButtonIndex) {
		if (index >= 0) {
			NSAssert(index<[_buttons count],nil,nil);
		} else {
			index = -1;
		}
		
		_cancelButtonIndex = index;
	}
}

- (BOOL)isVisible
{
	return (self.window != nil);
}

- (void)showInView:(UIView *)view
{
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated
{
	// If this is to be presented in a view that's in a popover, then we need to convert it to the sheet version
	// which is presented via showInView:. Otherwise, make a popover and show this as pointing at the given view/rect combo.
	if ([view.window.screen _popoverController]) {
		[self showInView:view];
	} else if (!_popoverController) {
		UIViewController *controller = [[UIViewController new] autorelease];
		controller.view = self;
		controller.contentSizeForViewInPopover = [self _viewSize];
		
		_popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
		_popoverController.delegate = self;
		
		if (_delegateHas.willPresentActionSheet) {
			[_delegate willPresentActionSheet:self];
		}

		[_popoverController presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:animated];

		if (_delegateHas.didPresentActionSheet) {
			[_delegate didPresentActionSheet:self];
		}
	}
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
	if (_popoverController) {
		[_popoverController dismissPopoverAnimated:animated];
		[_popoverController release];
		_popoverController = nil;
	}
}

- (void)_clickedButtonAtIndex:(NSInteger)index
{
	if (_delegateHas.clickedButtonAtIndex){
		[_delegate actionSheet:self clickedButtonAtIndex:index];
	}
	
	if (index == _cancelButtonIndex && _delegateHas.actionSheetCancel) {
		[_delegate actionSheetCancel:self];
	}
	
	if (_delegateHas.willDismissWithButtonIndex) {
		[_delegate actionSheet:self willDismissWithButtonIndex:index];
	}
	
	[self dismissWithClickedButtonIndex:index animated:YES];
	
	if (_delegateHas.didDismissWithButtonIndex) {
		[_delegate actionSheet:self didDismissWithButtonIndex:index];
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	if (_popoverController == popoverController) {
		[_popoverController release];
		_popoverController = nil;
		[self _clickedButtonAtIndex:_cancelButtonIndex];
	}
}

- (void)_buttonTapped:(id)sender
{
	NSInteger index = [_buttons indexOfObject:sender];
	if (index != NSNotFound) {
		[self _clickedButtonAtIndex:index];
	}
}

@end
