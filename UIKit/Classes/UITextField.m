//  Created by Sean Heber on 6/25/10.
#import "UITextField.h"
#import "UIView+UIPrivate.h"
#import "UIColor+UIPrivate.h"
#import "UIWindow.h"
#import "UIScreen+UIPrivate.h"
#import "UIFont+UIPrivate.h"
#import "UIImage.h"
#import <AppKit/AppKit.h>

@interface UITextField () <NSTextFieldDelegate>
- (BOOL)_delegateShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
@end

@interface _UITextFieldFormatter : NSFormatter {
	UITextField *textField;
}
@end

@implementation _UITextFieldFormatter

- (id)initWithNonretainedUITextField:(UITextField *)theTextField
{
	if ((self=[super init])) {
		textField = theTextField;
	}
	return self;
}

- (NSString *)stringForObjectValue:(id)anObject
{
	if ([anObject isKindOfClass:[NSString class]]) {
		return anObject;
	}
	return nil;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
	*anObject = string;
	return YES;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString **)error
{
	CGFloat endLength = [origString length] - origSelRange.location - origSelRange.length;
	NSString *replacementString = [*partialStringPtr substringWithRange:NSMakeRange(origSelRange.location, [*partialStringPtr length]-origSelRange.location-endLength)];
	return [textField _delegateShouldChangeCharactersInRange:origSelRange replacementString:replacementString];
}

@end

@implementation UITextField
@synthesize delegate=_delegate, font=_font, textColor=_textColor, background=_background, disabledBackground=_disabledBackground;
@synthesize clearButtonMode=_clearButtonMode, leftView=_leftView, rightView=_rightView, leftViewMode=_leftViewMode, rightViewMode=_rightViewMode;

- (void)_configureTextField:(NSTextField *)textField
{
	[textField setWantsLayer:YES];
	[textField setDrawsBackground:NO];
	[[textField layer] setGeometryFlipped:YES];
	[[textField cell] setFocusRingType:NSFocusRingTypeNone];
	[[textField cell] setLineBreakMode:NSLineBreakByTruncatingHead];
	[textField setTarget:self];
	[textField setAction:@selector(_textFieldAction)];
	[textField setDelegate:self];
	
	_UITextFieldFormatter *formatter = [[_UITextFieldFormatter alloc] initWithNonretainedUITextField:self];
	[textField setFormatter:formatter];
	[formatter release];
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_textField = [(NSTextField *)[NSTextField alloc] initWithFrame:NSRectFromCGRect(self.bounds)];
		[self _configureTextField:_textField];
		
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
	[_textField removeFromSuperview];		// meh.. shouldn't do this sort of thing in dealloc, but what can I do?
	[_font release];
	[_textColor release];
	[_textField release];
	[_leftView release];
	[_rightView release];
	[_background release];
	[_disabledBackground release];
	[super dealloc];
}

- (void)layoutSubviews
{
	[[_textField layer] setFrame:self.bounds];
	[self.layer insertSublayer:[_textField layer] atIndex:0];
}

- (void)_updateNSTextFieldFrame
{
	if (self.window) {
		CGRect windowRect = [self.window convertRect:self.frame fromView:self.superview];
		CGRect screenRect = [self.window convertRect:windowRect toWindow:nil];
		[_textField setFrame:NSRectFromCGRect(screenRect)];
		[[self.window.screen _NSView] addSubview:_textField];
	} else {
		[_textField removeFromSuperview];
	}
}

- (void)_boundsSizeDidChange
{
	[self _updateNSTextFieldFrame];
	[super _boundsSizeDidChange];
}

- (void)_hierarchyPositionDidChange
{
	[self _updateNSTextFieldFrame];
	[super _hierarchyPositionDidChange];
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
	return [_textField isKindOfClass:[NSSecureTextField class]];
}

- (void)setSecureTextEntry:(BOOL)secure
{
	if (self.secureTextEntry != secure) {
		[_textField removeFromSuperview];
		
		Class fieldClass = secure? [NSSecureTextField class] : [NSTextField class];
		NSTextField *newField = [(NSTextField *)[fieldClass alloc] initWithFrame:[_textField frame]];
		[self _configureTextField:newField];

		[[newField cell] setPlaceholderString:[[_textField cell] placeholderString]];
		[newField setBezeled:[_textField isBezeled]];
		[newField setBezelStyle:[_textField bezelStyle]];
		[newField setBordered:[_textField isBordered]];
		[newField setStringValue:[_textField stringValue]];
		[newField setTextColor:[_textField textColor]];
		[newField setFont:[_textField font]];
		
		[_textField release];
		_textField = newField;

		[self _updateNSTextFieldFrame];
	}
}

- (NSString *)placeholder
{
	return [[_textField cell] placeholderString];
}

- (void)setPlaceholder:(NSString *)thePlaceholder
{
	[[_textField cell] setPlaceholderString:thePlaceholder];
}

- (UITextBorderStyle)borderStyle
{
	if ([_textField isBezeled]) {
		if ([_textField bezelStyle] == NSTextFieldRoundedBezel) {
			return UITextBorderStyleRoundedRect;
		} else {
			return UITextBorderStyleBezel;
		}
	} else if ([_textField isBordered]) {
		return UITextBorderStyleLine;
	} else {
		return UITextBorderStyleNone;
	}
}

- (void)setBorderStyle:(UITextBorderStyle)style
{
	switch (style) {
		case UITextBorderStyleNone:
			[_textField setBezeled:NO];
			[_textField setBordered:NO];
			break;
			
		case UITextBorderStyleLine:
			[_textField setBezeled:NO];
			[_textField setBordered:YES];
			break;
			
		case UITextBorderStyleBezel:
			[_textField setBordered:NO];
			[_textField setBezeled:YES];
			[_textField setBezelStyle:NSTextFieldSquareBezel];
			break;
			
		case UITextBorderStyleRoundedRect:
			[_textField setBordered:NO];
			[_textField setBezeled:YES];
			[_textField setBezelStyle:NSTextFieldRoundedBezel];
			break;
	}
}

- (void)setFont:(UIFont *)newFont
{
	NSAssert((newFont != nil), nil);
	if (newFont != _font) {
		[_font release];
		_font = [newFont retain];
		[_textField setFont:[_font _NSFont]];
	}
}

- (void)setTextColor:(UIColor *)newColor
{
	if (newColor != _textColor) {
		[_textColor release];
		_textColor = [newColor retain];
		[_textField setTextColor:[_textColor _NSColor]];
	}
}

- (NSString *)text
{
	return [_textField stringValue];
}

- (void)setText:(NSString *)newText
{
	[_textField setStringValue:newText ?: @""];
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	if ([super becomeFirstResponder]) {
		return [[_textField window] makeFirstResponder:_textField];
	} else {
		return NO;
	}
}

- (BOOL)resignFirstResponder
{
	if ([super resignFirstResponder]) {
		return [[_textField window] makeFirstResponder:nil];
	} else {
		return NO;
	}
}

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
	if ([_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
		return [_delegate textFieldShouldBeginEditing:self];
	} else {
		return YES;
	}
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	if ([_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
		return [_delegate textFieldShouldEndEditing:self];
	} else {
		return YES;
	}
}

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
	if ([_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
		[_delegate textFieldDidBeginEditing:self];
	}
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	if ([_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
		[_delegate textFieldDidEndEditing:self];
	}
}

- (BOOL)_delegateShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
	if ([_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
		return [_delegate textField:self shouldChangeCharactersInRange:range replacementString:replacementString];
	} else {
		return YES;
	}
}

- (void)_textFieldAction
{
	if ([_delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
		// this is ignoring the return value.. and I don't know if this is the right spot to trigger this, but it'll work for now I suppose
		[_delegate textFieldShouldReturn:self];
	}
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
	return CGRectZero;
}

@end
