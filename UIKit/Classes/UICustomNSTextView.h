//  Created by Sean Heber on 8/26/10.
#import <AppKit/NSTextView.h>

@class CALayer, UICustomNSTextView;

@protocol UICustomNSTextViewDelegate <NSTextViewDelegate>
- (BOOL)textViewBecomeFirstResponder:(UICustomNSTextView *)textView;
- (BOOL)textViewResignFirstResponder:(UICustomNSTextView *)textView;
- (BOOL)textView:(UICustomNSTextView *)textView shouldAcceptKeyDown:(NSEvent *)event;
@end

@interface UICustomNSTextView: NSTextView {
	BOOL secureTextEntry;
}

- (id)initWithFrame:(NSRect)frame secureTextEntry:(BOOL)isSecure isField:(BOOL)isField;
- (void)setSecureTextEntry:(BOOL)isSecure;

- (BOOL)reallyBecomeFirstResponder;
- (BOOL)reallyResignFirstResponder;

- (id<UICustomNSTextViewDelegate>)delegate;
- (void)setDelegate:(id<UICustomNSTextViewDelegate>)d;

@end
