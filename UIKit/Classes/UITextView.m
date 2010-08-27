//  Created by Sean Heber on 6/29/10.
#import "UITextView.h"
#import "UIColor.h"
#import "UIFont.h"
#import "UITextLayer.h"
#import "UIScrollView+UIPrivate.h"

NSString *const UITextViewTextDidBeginEditingNotification = @"UITextViewTextDidBeginEditingNotification";
NSString *const UITextViewTextDidChangeNotification = @"UITextViewTextDidChangeNotification";
NSString *const UITextViewTextDidEndEditingNotification = @"UITextViewTextDidEndEditingNotification";

@interface UIScrollView () <UITextLayerContainerViewProtocol>
@end

@interface UITextView () <UITextLayerTextDelegate>
@end


@implementation UITextView
@synthesize dataDetectorTypes=_dataDetectorTypes;
@dynamic delegate;

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_textLayer = [[UITextLayer alloc] initWithContainerView:self textDelegate:self];
		[self.layer insertSublayer:_textLayer atIndex:0];

		self.textColor = [UIColor blackColor];
		self.font = [UIFont systemFontOfSize:17];
		self.dataDetectorTypes = UIDataDetectorTypeAll;
		self.editable = YES;
		self.contentMode = UIViewContentModeScaleToFill;
		self.clipsToBounds = YES;
	}
	return self;
}

- (void)dealloc
{
	[_textLayer release];
	[super dealloc];
}



- (void)layoutSubviews
{
	[super layoutSubviews];

	CGRect textRect = self.bounds;	
	if ([self _canScrollVertical]) {
		textRect.size.width -= _UIScrollViewScrollerSize;
	}
	_textLayer.frame = textRect;
}

- (void)setContentOffset:(CGPoint)theOffset animated:(BOOL)animated
{
	[super setContentOffset:theOffset animated:animated];
	[_textLayer setContentOffset:theOffset];
}

- (void)scrollRangeToVisible:(NSRange)range
{
	[_textLayer scrollRangeToVisible:range];
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


/*
- (BOOL)canBecomeFirstResponder
{
	return [_textContainer containerViewCanBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
	BOOL ok = [super becomeFirstResponder];
	if (ok) {
		[_textContainer containerViewDidBecomeFirstResponder];
	}
	return ok;
}

- (BOOL)canResignFirstResponder
{
	return [_textContainer containerViewCanResignFirstResponder];
}

- (BOOL)resignFirstResponder
{
	BOOL ok = [super resignFirstResponder];
	if (ok) {
		[_textContainer containerViewDidResignFirstResponder];
	}
	return ok;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self becomeFirstResponder];
}
 */



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

- (BOOL)isEditable
{
	return _textLayer.editable;
}

- (void)setEditable:(BOOL)editable
{
	_textLayer.editable = editable;
}

- (NSRange)selectedRange
{
	return _textLayer.selectedRange;
}

- (void)setSelectedRange:(NSRange)range
{
	_textLayer.selectedRange = range;
}

/*
- (id)mouseCursorForEvent:(UIEvent *)event
{
	return [_textContainer mouseCursorForEvent:event];
}
 */



- (void)setDelegate:(id<UITextViewDelegate>)theDelegate
{
	if (theDelegate != self.delegate) {
		[super setDelegate:theDelegate];
		_delegateHas.shouldBeginEditing = [theDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)];
		_delegateHas.didBeginEditing = [theDelegate respondsToSelector:@selector(textViewDidBeginEditing:)];
		_delegateHas.shouldEndEditing = [theDelegate respondsToSelector:@selector(textViewShouldEndEditing:)];
		_delegateHas.didEndEditing = [theDelegate respondsToSelector:@selector(textViewDidEndEditing:)];
		_delegateHas.shouldChangeText = [theDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)];
		_delegateHas.didChange = [theDelegate respondsToSelector:@selector(textViewDidChange:)];
		_delegateHas.didChangeSelection = [theDelegate respondsToSelector:@selector(textViewDidChangeSelection:)];
	}
}


- (BOOL)_textShouldBeginEditing
{
	return _delegateHas.shouldBeginEditing? [self.delegate textViewShouldBeginEditing:self] : YES;
}

- (void)_textDidBeginEditing
{
	if (_delegateHas.didBeginEditing) {
		[self.delegate textViewDidBeginEditing:self];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidBeginEditingNotification object:self];
}

- (BOOL)_textShouldEndEditing
{
	return _delegateHas.shouldEndEditing? [self.delegate textViewShouldEndEditing:self] : YES;
}

- (void)_textDidEndEditing
{
	if (_delegateHas.didEndEditing) {
		[self.delegate textViewDidEndEditing:self];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidEndEditingNotification object:self];
}

- (BOOL)_textShouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	return _delegateHas.shouldChangeText? [self.delegate textView:self shouldChangeTextInRange:range replacementText:text] : YES;
}

- (void)_textDidChange
{
	if (_delegateHas.didChange) {
		[self.delegate textViewDidChange:self];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
}

- (void)_textDidChangeSelection
{
	if (_delegateHas.didChangeSelection) {
		[self.delegate textViewDidChangeSelection:self];
	}
}

@end
