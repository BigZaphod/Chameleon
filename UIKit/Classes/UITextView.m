//  Created by Sean Heber on 6/29/10.
#import "UITextView.h"
#import "UIText.h"
#import "UIColor.h"
#import "UIFont.h"

/*
#import <AppKit/AppKit.h>
#import "UIWindow+UIPrivate.h"
#import "UIView+UIPrivate.h"
#import "UIScreen+UIPrivate.h"
*/

@implementation UITextView
@synthesize dataDetectorTypes=_dataDetectorTypes;
@dynamic delegate;

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_textContainer = [[UIText alloc] initWithContainerView:self];
		self.textColor = [UIColor blackColor];
		self.font = [UIFont systemFontOfSize:17];
		self.dataDetectorTypes = UIDataDetectorTypeAll;
		self.editable = YES;
	}
	return self;
}

- (void)dealloc
{
	[_textContainer release];
	[super dealloc];
}





- (UITextAutocapitalizationType)autocapitalizationType
{
	return UITextAutocapitalizationTypeNone;
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)type
{
}

- (UITextAutocorrectionType)autocorrectionType
{
	return UITextAutocorrectionTypeDefault;
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)type
{
}

- (BOOL)enablesReturnKeyAutomatically
{
	return YES;
}

- (void)setEnablesReturnKeyAutomatically:(BOOL)enabled
{
}

- (UIKeyboardAppearance)keyboardAppearance
{
	return UIKeyboardAppearanceDefault;
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)type
{
}

- (UIKeyboardType)keyboardType
{
	return UIKeyboardTypeDefault;
}

- (void)setKeyboardType:(UIKeyboardType)type
{
}

- (UIReturnKeyType)returnKeyType
{
	return UIReturnKeyDefault;
}

- (void)setReturnKeyType:(UIReturnKeyType)type
{
}

- (BOOL)isSecureTextEntry
{
	return NO;
}

- (void)setSecureTextEntry:(BOOL)secure
{
}



- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	BOOL ok = [super becomeFirstResponder];
	if (ok) {
		[_textContainer containerViewBecameFirstResponder];
	}
	return ok;
}

- (BOOL)resignFirstResponder
{
	BOOL ok = [super resignFirstResponder];
	if (ok) {
		[_textContainer containerViewResignedFirstResponder];
	}
	return ok;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self becomeFirstResponder];
}



- (UIFont *)font
{
	return _textContainer.font;
}

- (void)setFont:(UIFont *)newFont
{
	_textContainer.font = newFont;
}

- (UIColor *)textColor
{
	return _textContainer.textColor;
}

- (void)setTextColor:(UIColor *)newColor
{
	_textContainer.textColor = newColor;
}

- (NSString *)text
{
	return _textContainer.text;
}

- (void)setText:(NSString *)newText
{
	_textContainer.text = newText;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[_textContainer updateFrame];
}

- (void)willMoveToSuperview:(UIView *)view
{
	[_textContainer containerViewWillMoveToSuperview:view];
}

- (void)didMoveToSuperview
{
	[_textContainer containerViewDidMoveToSuperview];
}

- (void)drawRect:(CGRect)rect
{
	[_textContainer drawInRect:rect];
}

- (void)setHidden:(BOOL)hidden
{
	[super setHidden:hidden];
	[_textContainer setHidden:hidden];
}

- (BOOL)isEditable
{
	return _textContainer.editable;
}

- (void)setEditable:(BOOL)editable
{
	_textContainer.editable = editable;
}

- (id)mouseCursorForEvent:(UIEvent *)event
{
	return [_textContainer mouseCursorForEvent:event];
}

@end
