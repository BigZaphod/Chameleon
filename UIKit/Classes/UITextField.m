/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UITextField.h"
#import "UITextLayer.h"
#import "UIColor.h"
#import "UIFont.h"
#import "UIImage.h"
#import "UILabel.h"
#import <AppKit/NSCursor.h>

NSString *const UITextFieldTextDidBeginEditingNotification = @"UITextFieldTextDidBeginEditingNotification";
NSString *const UITextFieldTextDidChangeNotification = @"UITextFieldTextDidChangeNotification";
NSString *const UITextFieldTextDidEndEditingNotification = @"UITextFieldTextDidEndEditingNotification";

@interface UIControl () <UITextLayerContainerViewProtocol>
@end

@interface UITextField () <UITextLayerTextDelegate>
@end

@implementation UITextField {
    UILabel *_placeholderLabel;
    UITextLayer *_textLayer;
    
    struct {
        unsigned shouldBeginEditing : 1;
        unsigned didBeginEditing : 1;
        unsigned shouldEndEditing : 1;
        unsigned didEndEditing : 1;
        unsigned shouldChangeCharacters : 1;
        unsigned shouldClear : 1;
        unsigned shouldReturn : 1;
    } _delegateHas;
}
@synthesize inputAccessoryView, inputView;

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _placeholderLabel.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
        _placeholderLabel.hidden = NO;
        [self addSubview:_placeholderLabel];
        
        _textLayer = [[UITextLayer alloc] initWithContainer:self isField:YES];
        [self.layer addSublayer:_textLayer];

        self.textAlignment = UITextAlignmentLeft;
        self.font = [UIFont systemFontOfSize:17];
        self.borderStyle = UITextBorderStyleNone;
        self.textColor = [UIColor blackColor];
        self.clearButtonMode = UITextFieldViewModeNever;
        self.leftViewMode = UITextFieldViewModeNever;
        self.rightViewMode = UITextFieldViewModeNever;
        self.opaque = NO;
    }
    return self;
}

- (void)dealloc
{
    [_textLayer removeFromSuperlayer];
}

- (BOOL)_isLeftViewVisible
{
    return _leftView && (_leftViewMode == UITextFieldViewModeAlways
                         || (_editing && _leftViewMode == UITextFieldViewModeWhileEditing)
                         || (!_editing && _leftViewMode == UITextFieldViewModeUnlessEditing));
}

- (BOOL)_isRightViewVisible
{
    return _rightView && (_rightViewMode == UITextFieldViewModeAlways
                         || (_editing && _rightViewMode == UITextFieldViewModeWhileEditing)
                         || (!_editing && _rightViewMode == UITextFieldViewModeUnlessEditing));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    const CGRect bounds = self.bounds;
    _textLayer.frame = [self textRectForBounds:bounds];
    _placeholderLabel.frame = _textLayer.frame;
    [_placeholderLabel sizeToFit];
    
    if ([self _isLeftViewVisible]) {
        _leftView.hidden = NO;
        _leftView.frame = [self leftViewRectForBounds:bounds];
    } else {
        _leftView.hidden = YES;
    }

    if ([self _isRightViewVisible]) {
        _rightView.hidden = NO;
        _rightView.frame = [self rightViewRectForBounds:bounds];
    } else {
        _rightView.hidden = YES;
    }
}

- (void)setDelegate:(id<UITextFieldDelegate>)theDelegate
{
    if (theDelegate != _delegate) {
        _delegate = theDelegate;
        _delegateHas.shouldBeginEditing = [_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)];
        _delegateHas.didBeginEditing = [_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)];
        _delegateHas.shouldEndEditing = [_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)];
        _delegateHas.didEndEditing = [_delegate respondsToSelector:@selector(textFieldDidEndEditing:)];
        _delegateHas.shouldChangeCharacters = [_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)];
        _delegateHas.shouldClear = [_delegate respondsToSelector:@selector(textFieldShouldClear:)];
        _delegateHas.shouldReturn = [_delegate respondsToSelector:@selector(textFieldShouldReturn:)];
    }
}

- (NSString *)placeholder
{
    return _placeholderLabel.text;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholderLabel.text = placeholder;
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    _placeholderLabel.attributedText = attributedPlaceholder;
}
- (NSAttributedString *)attributedPlaceholder
{
    return _placeholderLabel.attributedText;
}

- (void)setBorderStyle:(UITextBorderStyle)style
{
    if (style != _borderStyle) {
        _borderStyle = style;
        [self setNeedsDisplay];
    }
}

- (void)setBackground:(UIImage *)aBackground
{
    if (aBackground != _background) {
        _background = aBackground;
        [self setNeedsDisplay];
    }
}

- (void)setDisabledBackground:(UIImage *)aBackground
{
    if (aBackground != _disabledBackground) {
        _disabledBackground = aBackground;
        [self setNeedsDisplay];
    }
}

- (void)setLeftView:(UIView *)leftView
{
    if (leftView != _leftView) {
        [_leftView removeFromSuperview];
        _leftView = leftView;
        [self addSubview:_leftView];
    }
}

- (void)setRightView:(UIView *)rightView
{
    if (rightView != _rightView) {
        [_rightView removeFromSuperview];
        _rightView = rightView;
        [self addSubview:_rightView];
    }
}

- (void)setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(frame,self.frame)) {
        [super setFrame:frame];
        [self setNeedsDisplay];
    }
}


- (CGRect)borderRectForBounds:(CGRect)bounds
{
    return bounds;
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    if (_leftView) {
        const CGRect frame = _leftView.frame;
        bounds.origin.x = 0;
        bounds.origin.y = (bounds.size.height / 2.f) - (frame.size.height/2.f);
        bounds.size = frame.size;
        return CGRectIntegral(bounds);
    } else {
        return CGRectZero;
    }
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    if (_rightView) {
        const CGRect frame = _rightView.frame;
        bounds.origin.x = bounds.size.width - frame.size.width;
        bounds.origin.y = (bounds.size.height / 2.f) - (frame.size.height/2.f);
        bounds.size = frame.size;
        return CGRectIntegral(bounds);
    } else {
        return CGRectZero;
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    // Docs say:
    // The default implementation of this method returns a rectangle that is derived from the control’s original bounds,
    // but which does not include the area occupied by the receiver’s border or overlay views.
    
    // It appears what happens is something like this:
    // check border type:
    //   if no border, skip to next major step
    //   if has border, set textRect = borderBounds, then inset textRect according to border style
    // check if textRect overlaps with leftViewRect, if it does, make it smaller
    // check if textRect overlaps with rightViewRect, if it does, make it smaller
    // check if textRect overlaps with clearButtonRect (if currently needed?), if it does, make it smaller
    
    CGRect textRect = bounds;
    
    if (_borderStyle != UITextBorderStyleNone) {
        textRect = [self borderRectForBounds:bounds];
        // TODO: inset the bounds based on border types...
    }
    
    // Going to go ahead and assume that the left view is on the left, the right view is on the right, and there's space between..
    // I imagine this is a dangerous assumption...
    if ([self _isLeftViewVisible]) {
        CGRect overlap = CGRectIntersection(textRect,[self leftViewRectForBounds:bounds]);
        if (!CGRectIsNull(overlap)) {
            textRect = CGRectOffset(textRect, overlap.size.width, 0);
            textRect.size.width -= overlap.size.width;
        }
    }
    
    if ([self _isRightViewVisible]) {
        CGRect overlap = CGRectIntersection(textRect,[self rightViewRectForBounds:bounds]);
        if (!CGRectIsNull(overlap)) {
            textRect = CGRectOffset(textRect, -overlap.size.width, 0);
            textRect.size.width -= overlap.size.width;
        }
    }
    
    return CGRectIntegral(bounds);
}



- (void)drawPlaceholderInRect:(CGRect)rect
{
}

- (void)drawTextInRect:(CGRect)rect
{
}

- (void)drawRect:(CGRect)rect
{
    UIImage *background = self.enabled? _background : _disabledBackground;
    [background drawInRect:self.bounds];
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
    BOOL result = [super becomeFirstResponder];
    
    if (result && (result = [_textLayer becomeFirstResponder])) {
        [self _textDidBeginEditing];
    }
    
    return result;
}

- (BOOL)resignFirstResponder
{
    if ([super resignFirstResponder]) {
        return [_textLayer resignFirstResponder];
    } else {
        return NO;
    }
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

- (UITextAlignment)textAlignment
{
    return _textLayer.textAlignment;
}

- (void)setTextAlignment:(UITextAlignment)textAlignment
{
    _textLayer.textAlignment = textAlignment;
}

- (NSString *)text
{
    return _textLayer.text;
}

- (void)setText:(NSString *)newText
{
    _textLayer.text = newText;
    _placeholderLabel.hidden = ([self.text length] > 0);
}

- (BOOL)_textShouldBeginEditing
{
    return _delegateHas.shouldBeginEditing? [_delegate textFieldShouldBeginEditing:self] : YES;
}

- (void)_textDidBeginEditing
{
    BOOL shouldClear = _clearsOnBeginEditing;

    if (shouldClear && _delegateHas.shouldClear) {
        shouldClear = [_delegate textFieldShouldClear:self];
    }

    if (shouldClear) {
        // this doesn't work - it can cause an exception to trigger. hrm...
        // so... rather than worry too much about it right now, just gonna delay it :P
        //self.text = @"";
        [self performSelector:@selector(setText:) withObject:@"" afterDelay:0];
    }
    
    _editing = YES;
    [self setNeedsDisplay];
    [self setNeedsLayout];

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
    _editing = NO;
    [self setNeedsDisplay];
    [self setNeedsLayout];

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
    _placeholderLabel.hidden = ([self.text length] > 0);
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self];
}

- (void)_textDidReceiveReturnKey
{
    if (_delegateHas.shouldReturn) {
        [_delegate textFieldShouldReturn:self];
    }
}

- (NSString *)description
{
    NSString *textAlignment = @"";
    switch (self.textAlignment) {
        case UITextAlignmentLeft:
            textAlignment = @"Left";
            break;
        case UITextAlignmentCenter:
            textAlignment = @"Center";
            break;
        case UITextAlignmentRight:
            textAlignment = @"Right";
            break;
        case UITextAlignmentJustified:
            textAlignment = @"Justified";
            break;
        case UITextAlignmentNatural:
            textAlignment = @"Natural";
            break;
    }
    return [NSString stringWithFormat:@"<%@: %p; textAlignment = %@; editing = %@; textColor = %@; font = %@; delegate = %@>", [self className], self, textAlignment, (self.editing ? @"YES" : @"NO"), self.textColor, self.font, self.delegate];
}

- (id)mouseCursorForEvent:(UIEvent *)event
{
    return [NSCursor IBeamCursor];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [_textLayer sizeThatFits:size];
}

#pragma mark UITextInput

- (void)setSelectedTextRange:(UITextRange *)range
{
}

- (UITextRange *)selectedTextRange
{
    return nil;
}

- (UITextRange *)beginningOfDocument
{
    return nil;
}

- (UITextPosition *)endOfDocument
{
    return nil;
}

- (NSInteger)offsetFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
    return 0;
}

- (UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset
{
    return nil;
}

- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
    return nil;
}

@end


@implementation UIView (UITextField)

- (BOOL)endEditing:(BOOL)force
{
    if ([self isFirstResponder]) {
        if (force || [self canResignFirstResponder]) {
            return [self resignFirstResponder];
        }
    } else {
        for (UIView *view in self.subviews) {
            if ([view endEditing:force]) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
