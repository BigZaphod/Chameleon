//  Created by Sean Heber on 6/25/10.
#import "UITextField.h"
#import "UITextLayer.h"
#import "UIColor.h"
#import "UIFont.h"

NSString *const UITextFieldTextDidBeginEditingNotification = @"UITextFieldTextDidBeginEditingNotification";
NSString *const UITextFieldTextDidChangeNotification = @"UITextFieldTextDidChangeNotification";
NSString *const UITextFieldTextDidEndEditingNotification = @"UITextFieldTextDidEndEditingNotification";

@interface UIControl () <UITextLayerContainerViewProtocol>
@end

@interface UITextField () <UITextLayerTextDelegate>
@end

@implementation UITextField
@synthesize delegate=_delegate, background=_background, disabledBackground=_disabledBackground;
@synthesize clearButtonMode=_clearButtonMode, leftView=_leftView, rightView=_rightView, leftViewMode=_leftViewMode, rightViewMode=_rightViewMode;

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_textLayer = [[UITextLayer alloc] initWithContainer:self isField:YES];
		[self.layer insertSublayer:_textLayer atIndex:0];

		self.font = [UIFont systemFontOfSize:17];
		self.borderStyle = UITextBorderStyleNone;
		self.textColor = [UIColor blackColor];
		self.clearButtonMode = UITextFieldViewModeNever;
		self.leftViewMode = UITextFieldViewModeNever;
		self.rightViewMode = UITextFieldViewModeNever;
	}
	return self;
}

- (void)dealloc
{
	[_textLayer removeFromSuperlayer];
	[_textLayer release];
	[_leftView release];
	[_rightView release];
	[_background release];
	[_disabledBackground release];
	[super dealloc];
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	_textLayer.frame = self.bounds;
}


- (void)setDelegate:(id<UITextFieldDelegate>)theDelegate
{
	if (theDelegate != _delegate) {
		_delegate = theDelegate;
		_delegateHas.shouldBeginEditing = [_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)];
		_delegateHas.didBeginEditing = [_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)];
		_delegateHas.shouldEndEditing = [_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)];
		_delegateHas.didEndEditing = [_delegate respondsToSelector:@selector(textFieldDidEndEditing:)];
		_delegateHas.shouldChangeCharacters = [_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementText:)];
		_delegateHas.shouldClear = [_delegate respondsToSelector:@selector(textFieldShouldClear:)];
		_delegateHas.shouldReturn = [_delegate respondsToSelector:@selector(textFieldShouldReturn:)];
	}
}

- (NSString *)placeholder
{
	return nil;
}

- (void)setPlaceholder:(NSString *)thePlaceholder
{
}

- (UITextBorderStyle)borderStyle
{
	return UITextBorderStyleNone;
}

- (void)setBorderStyle:(UITextBorderStyle)style
{
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
	return CGRectZero;
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
	return [_textLayer isSecureTextEntry];
}

- (void)setSecureTextEntry:(BOOL)secure
{
	[_textLayer setSecureTextEntry:secure];
}


- (BOOL)canBecomeFirstResponder
{
	return (self.window != nil);
}

- (BOOL)becomeFirstResponder
{
	return [_textLayer becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
	return [_textLayer resignFirstResponder];
}



- (UIFont *)font
{
	return _textLayer.font;
}

- (void)setFont:(UIFont *)newFont
{
	_textLayer.font = newFont;
}

- (UIColor *)textColor
{
	return _textLayer.textColor;
}

- (void)setTextColor:(UIColor *)newColor
{
	_textLayer.textColor = newColor;
}

- (NSString *)text
{
	return _textLayer.text;
}

- (void)setText:(NSString *)newText
{
	_textLayer.text = newText;
}




- (BOOL)_textShouldBeginEditing
{
	return _delegateHas.shouldBeginEditing? [_delegate textFieldShouldBeginEditing:self] : YES;
}

- (void)_textDidBeginEditing
{
	if (_delegateHas.didBeginEditing) {
		[_delegate textFieldDidBeginEditing:self];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidBeginEditingNotification object:self];
}

- (BOOL)_textShouldEndEditing
{
	return _delegateHas.shouldEndEditing? [_delegate textFieldShouldEndEditing:self] : YES;
}

- (void)_textDidEndEditing
{
	if (_delegateHas.didEndEditing) {
		[_delegate textFieldDidEndEditing:self];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidEndEditingNotification object:self];
}

- (BOOL)_textShouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	return _delegateHas.shouldChangeCharacters? [_delegate textField:self shouldChangeCharactersInRange:range replacementString:text] : YES;
}

- (void)_textDidChange
{
	[[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self];
}

- (void)_textDidReceiveReturnKey
{
	if (_delegateHas.shouldReturn) {
		[_delegate textFieldShouldReturn:self];
	}
}

@end
