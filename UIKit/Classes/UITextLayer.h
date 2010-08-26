//  Created by Sean Heber on 8/26/10.
#import <QuartzCore/CALayer.h>

@class UICustomNSClipView, UICustomNSTextView, UIColor, UIFont, NSTextStorage, UIScrollView;

@interface UITextLayer : CALayer {
	__weak UIScrollView *containerView;
	UICustomNSTextView *textView;
	UICustomNSClipView *clipView;
	NSTextStorage *textStorage;
	BOOL secureTextEntry;
	BOOL editable;
	UIColor *textColor;
	UIFont *font;
}

- (id)initWithContainerView:(UIScrollView *)aView;
- (void)setContentOffset:(CGPoint)contentOffset;
- (void)setHidden:(BOOL)hide;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;

@end
