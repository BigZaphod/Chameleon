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

#import "UITextLayer.h"
#import "UIScrollView.h"
#import "UICustomNSTextView.h"
#import "UICustomNSClipView.h"
#import "UIWindow.h"
#import "UIKitView.h"
#import "AppKitIntegration.h"
#import "UIView+UIPrivate.h"
#import "UIKey.h"
#import <AppKit/NSLayoutManager.h>
#import <AppKit/NSWindow.h>

@interface UITextLayer () <UICustomNSClipViewBehaviorDelegate, UICustomNSTextViewDelegate>
- (void)removeNSView;
@end

@implementation UITextLayer {
    UIView <UITextLayerContainerViewProtocol, UITextLayerTextDelegate> *_containerView;
    BOOL _containerCanScroll;
    UICustomNSTextView *_textView;
    UICustomNSClipView *_clipView;
    BOOL _changingResponderStatus;
    
    struct {
        unsigned didChange : 1;
        unsigned didChangeSelection : 1;
        unsigned didReturnKey : 1;
    } _textDelegateHas;
}

- (id)initWithContainer:(UIView <UITextLayerContainerViewProtocol, UITextLayerTextDelegate> *)aView isField:(BOOL)isField
{
    if ((self=[super init])) {
        self.masksToBounds = NO;

        _containerView = aView;

        _textDelegateHas.didChange = [_containerView respondsToSelector:@selector(_textDidChange)];
        _textDelegateHas.didChangeSelection = [_containerView respondsToSelector:@selector(_textDidChangeSelection)];
        _textDelegateHas.didReturnKey = [_containerView respondsToSelector:@selector(_textDidReceiveReturnKey)];
        
        _containerCanScroll = [_containerView respondsToSelector:@selector(setContentOffset:)]
            && [_containerView respondsToSelector:@selector(contentOffset)]
            && [_containerView respondsToSelector:@selector(setContentSize:)]
            && [_containerView respondsToSelector:@selector(contentSize)]
            && [_containerView respondsToSelector:@selector(isScrollEnabled)];
        
        _clipView = [(UICustomNSClipView *)[UICustomNSClipView alloc] initWithFrame:NSMakeRect(0,0,100,100)];
        _textView = [(UICustomNSTextView *)[UICustomNSTextView alloc] initWithFrame:[_clipView frame] secureTextEntry:_secureTextEntry isField:isField];

        [_textView setDelegate:self];
        [_clipView setDocumentView:_textView];

        self.textAlignment = UITextAlignmentLeft;
        [self setNeedsLayout];
    }
    return self;
}

- (void)dealloc
{
    [_textView setDelegate:nil];
    [self removeNSView];
}

// Need to prevent Core Animation effects from happening... very ugly otherwise.
- (id < CAAction >)actionForKey:(NSString *)aKey
{
    return nil;
}

- (void)addNSView
{
    if (_containerCanScroll) {
        [_clipView scrollToPoint:NSPointFromCGPoint([_containerView contentOffset])];
    } else {
        [_clipView scrollToPoint:NSZeroPoint];
    }

    _clipView.parentLayer = self;
    _clipView.behaviorDelegate = self;

    [_containerView.window.screen.UIKitView addSubview:_clipView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScrollViewContentOffset) name:NSViewBoundsDidChangeNotification object:_clipView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hierarchyDidChangeNotification:) name:UIViewFrameDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hierarchyDidChangeNotification:) name:UIViewBoundsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hierarchyDidChangeNotification:) name:UIViewDidMoveToSuperviewNotification object:nil];
}

- (void)removeNSView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:_clipView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIViewFrameDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIViewBoundsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIViewDidMoveToSuperviewNotification object:nil];
    
    _clipView.parentLayer = nil;
    _clipView.behaviorDelegate = nil;

    [_clipView removeFromSuperview];
}

- (void)updateScrollViewContentSize
{
    if (_containerCanScroll) {
        // also update the content size in the UIScrollView
        const NSRect docRect = [_clipView documentRect];
        [_containerView setContentSize:CGSizeMake(docRect.size.width+docRect.origin.x, docRect.size.height+docRect.origin.y)];
    }
}

- (BOOL)shouldBeVisible
{
    return ([_containerView window] && (self.superlayer == [_containerView layer]) && !self.hidden && ![_containerView isHidden]);
}

- (void)updateNSViews
{
    if ([self shouldBeVisible]) {
        if (![_clipView superview]) {
            [self addNSView];
        }
        
        UIWindow *window = [_containerView window];
        const CGRect windowRect = [window convertRect:self.frame fromView:_containerView];
        const CGRect screenRect = [window convertRect:windowRect toWindow:nil];
        NSRect desiredFrame = NSRectFromCGRect(screenRect);

        [_clipView setFrame:desiredFrame];
        [self updateScrollViewContentSize];
    } else {
        [self removeNSView];
    }
}

- (void)layoutSublayers
{
    [self updateNSViews];
    [super layoutSublayers];
}

- (void)removeFromSuperlayer
{
    [super removeFromSuperlayer];
    [self updateNSViews];
}

- (void)setHidden:(BOOL)hide
{
    if (hide != self.hidden) {
        [super setHidden:hide];
        [self updateNSViews];
    }
}

- (void)hierarchyDidChangeNotification:(NSNotification *)note
{
    if ([_containerView isDescendantOfView:[note object]]) {
        if ([self shouldBeVisible]) {
            [self setNeedsLayout];
        } else {
            [self removeNSView];
        }
    }
}


- (void)setContentOffset:(CGPoint)contentOffset
{
    NSPoint point = [_clipView constrainScrollPoint:NSPointFromCGPoint(contentOffset)];
    [_clipView scrollToPoint:point];
}

- (void)updateScrollViewContentOffset
{
    if (_containerCanScroll) {
        [_containerView setContentOffset:NSPointToCGPoint([_clipView bounds].origin)];
    }
}

- (void)setFont:(UIFont *)newFont
{
    assert(newFont != nil);
    if (newFont != _font) {
        _font = newFont;
        [_textView setFont:[_font NSFont]];
    }
}

- (void)setTextColor:(UIColor *)newColor
{
    if (newColor != _textColor) {
        _textColor = newColor;
        [_textView setTextColor:[_textColor NSColor]];
    }
}

- (NSString *)text
{
    return [_textView string];
}

- (void)setText:(NSString *)newText
{
    [_textView setString:newText ?: @""];
    [self updateScrollViewContentSize];
}

- (void)setSecureTextEntry:(BOOL)s
{
    if (s != _secureTextEntry) {
        _secureTextEntry = s;
        [_textView setSecureTextEntry:_secureTextEntry];
    }
}

- (void)setEditable:(BOOL)edit
{
    if (_editable != edit) {
        _editable = edit;
        [_textView setEditable:_editable];
    }
}

- (void)scrollRangeToVisible:(NSRange)range
{
    [_textView scrollRangeToVisible:range];
}

- (NSRange)selectedRange
{
    return [_textView selectedRange];
}

- (void)setSelectedRange:(NSRange)range
{
    [_textView setSelectedRange:range];
}

- (void)setTextAlignment:(UITextAlignment)textAlignment
{
    switch (textAlignment) {
        case UITextAlignmentLeft:
            [_textView setAlignment:NSLeftTextAlignment];
            break;
        case UITextAlignmentCenter:
            [_textView setAlignment:NSCenterTextAlignment];
            break;
        case UITextAlignmentRight:
            [_textView setAlignment:NSRightTextAlignment];
            break;
    }
}

- (UITextAlignment)textAlignment
{
    switch ([_textView alignment]) {
        case NSCenterTextAlignment:
            return UITextAlignmentCenter;
        case NSRightTextAlignment:
            return UITextAlignmentRight;
        default:
            return UITextAlignmentLeft;
    }
}

// this is used to fake out AppKit when the UIView that owns this layer/editor stuff is actually *behind* another UIView. Since the NSViews are
// technically above all of the UIViews, they'd normally capture all clicks no matter what might happen to be obscuring them. That would obviously
// be less than ideal. This makes it ideal. Awesome.
- (BOOL)hitTestForClipViewPoint:(NSPoint)point
{
    UIScreen *screen = [_containerView window].screen;
    
    if (screen) {
        return (_containerView == [screen.UIKitView hitTestUIView:point]);
    }

    return NO;
}

- (BOOL)clipViewShouldScroll
{
    return _containerCanScroll && [_containerView isScrollEnabled];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    NSRect rect = [_textView.layoutManager usedRectForTextContainer:_textView.textContainer];
    return CGSizeMake(MIN(rect.size.width, size.width), rect.size.height);
}



- (BOOL)textShouldBeginEditing:(NSText *)aTextObject
{
    return [_containerView _textShouldBeginEditing];
}

- (BOOL)textShouldEndEditing:(NSText *)aTextObject
{
    return [_containerView _textShouldEndEditing];
}

- (void)textDidEndEditing:(NSNotification *)aNotification
{
    [_containerView _textDidEndEditing];
}

- (void)textDidChange:(NSNotification *)aNotification
{
    if (_textDelegateHas.didChangeSelection) {
        // IMPORTANT! see notes about why this hack exists down in -textViewDidChangeSelection:!
        [NSObject cancelPreviousPerformRequestsWithTarget:_containerView selector:@selector(_textDidChangeSelection) object:nil];
    }

    if (_textDelegateHas.didChange) {
        [_containerView _textDidChange];
    }
}

- (void)textViewDidChangeSelection:(NSNotification *)aNotification
{
    if (_textDelegateHas.didChangeSelection) {
        // this defers the sending of the selection change delegate message. the reason is that on the real iOS, Apple does not appear to send
        // the selection changing delegate messages when text is actually changing. since I can't find a decent way to check here if text is
        // actually changing or if the cursor is just moving, I'm deferring the actual sending of this message. above in -textDidChange:, it
        // cancels the deferred send if it ends up that text actually changed. this only works if -textDidChange: is sent after
        // -textViewDidChangeSelection: which appears to be the case, but I don't think this is documented anywhere so this could possibly
        // break someday. anyway, the end result of this nasty hack is that UITextLayer shouldn't send out the selection changing notifications
        // while text is being changed, which mirrors how the real UIKit appears to work in this regard. note that the real UIKit also appears
        // to NOT send the selection change notification if you had multiple characters selected and then typed a single character thus
        // replacing the selected text with the single new character. happily this hack appears to function the same way.
        [_containerView performSelector:@selector(_textDidChangeSelection) withObject:nil afterDelay:0];
    }
}

- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    // always prevent newlines when in field editing mode. this seems like a heavy-handed way of doing it, but it's also easy and quick.
    // it should really probably be in the UICustomNSTextView class somewhere and not here, but this works okay, too, I guess.
    // this is also being done in doCommandBySelector: below, but it's done here as well to prevent pasting stuff in with newlines in it.
    // seems like a hack, I dunno.
    if ([_textView isFieldEditor] && ([replacementString rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound)) {
        return NO;
    } else {
        return [_containerView _textShouldChangeTextInRange:affectedCharRange replacementText:replacementString];
    }
}

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
    // this makes sure there's no newlines added when in field editing mode.
    // it also allows us to handle when return/enter is pressed differently for fields. Dunno if there's a better way or not.
    if ([_textView isFieldEditor] && ((aSelector == @selector(insertNewline:) || (aSelector == @selector(insertNewlineIgnoringFieldEditor:))))) {
        if (_textDelegateHas.didReturnKey) {
            [_containerView _textDidReceiveReturnKey];
        }
        return YES;
    }
    
    return NO;
}

- (BOOL)textViewBecomeFirstResponder:(UICustomNSTextView *)aTextView
{
    if (_changingResponderStatus) {
        return [aTextView reallyBecomeFirstResponder];
    } else {
        return [_containerView becomeFirstResponder];
    }
}

- (BOOL)textViewResignFirstResponder:(UICustomNSTextView *)aTextView
{
    if (_changingResponderStatus) {
        return [aTextView reallyResignFirstResponder];
    } else {
        return [_containerView resignFirstResponder];
    }
}

- (BOOL)becomeFirstResponder
{
    if ([self shouldBeVisible] && ![_clipView superview]) {
        [self addNSView];
    }
    
    _changingResponderStatus = YES;
    const BOOL result = [[_textView window] makeFirstResponder:_textView];
    _changingResponderStatus = NO;

    return result;
}

- (BOOL)resignFirstResponder
{
    _changingResponderStatus = YES;
    const BOOL result = [[_textView window] makeFirstResponder:_containerView.window.screen.UIKitView];
    _changingResponderStatus = NO;
    return result;
}

- (BOOL)textView:(UICustomNSTextView *)aTextView shouldAcceptKeyDown:(NSEvent *)theNSEvent
{
    UIKey *key = [[UIKey alloc] initWithNSEvent:theNSEvent];
    
    if (key.action) {
        [aTextView doCommandBySelector:key.action];
        return NO;
    } else {
        return YES;
    }
}

@end
